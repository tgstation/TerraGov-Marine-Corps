/datum/component/ability/devour
	var/atom/movable/devoured
	var/datum/action/ability/regurgitate/button
	var/list/devour_types_permitted
	var/list/species_forbidden
	var/release_timer

/datum/component/ability/devour/Initialize(list/devour_types_permitted, list/species_forbidden)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	button = new /datum/action/ability/regurgitate
	button.give_action(parent)
	if(islist(devour_types_permitted))
		src.devour_types_permitted = typecacheof(devour_types_permitted)
	if(islist(species_forbidden))
		src.species_forbidden = typecacheof(species_forbidden)

/datum/component/ability/devour/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_GRAB_SELF_ATTACK, .proc/devour)
	RegisterSignal(parent, COMSIG_XENOABILITY_REGURGITATE, .proc/release)

/datum/component/ability/devour/UnregisterFromParent()
	. = ..()
	UnregisterFromParent(parent, list(
		COMSIG_GRAB_SELF_ATTACK,
		COMSIG_XENOABILITY_REGURGITATE
	))

/datum/component/ability/devour/proc/devour(datum/source)
	if(devoured)
		to_chat(parent, "<span class='warning'>You already have something in your belly, there's no way that will fit.</span>")
		return NONE
	var/turf/T = get_turf(parent)
	for(var/i in T)
		var/atom/A = i
		if(A == parent)
			continue
		if(A.density)
			to_chat(parent, "<span class='danger'>You can't do that here!</span>")
			return NONE

	var/mob/P = parent
	var/atom/movable/grab = P.pulling
	var/mob/as_mob = grab

	if(!is_type_in_typecache(grab, devour_types_permitted) || is_species_in_list(grab, species_forbidden))
		to_chat(P, "<span class='warning'>That wouldn't taste very good.</span>")
		return NONE
	if(ismob(grab))
		if(as_mob.buckled)
			to_chat(P, "<span class='warning'>[as_mob] is buckled to something.</span>")
			return NONE
		if(as_mob.stat == DEAD)
			to_chat(P, "<span class='warning'>Ew, [as_mob] is already starting to rot.</span>")
			return NONE

	P.visible_message("<span class='danger'>[P] starts to devour [grab]!</span>", \
	"<span class='danger'>You start to devour [grab]!</span>", null, 5)

	if(!do_after(P, 5 SECONDS, FALSE, grab, BUSY_ICON_DANGER, extra_checks = CALLBACK(src, .proc/can_devour_grabbed, grab)))
		to_chat(P, "<span class='warning'>You stop devouring \the [grab]. \He probably tasted gross anyways.</span>")
		return NONE

	P.visible_message("<span class='warning'>[P] devours [grab]!</span>", \
	"<span class='warning'>You devour [grab]!</span>", null, 5)

	grab.moveToNullspace()
	devoured = grab
	devoured.forceMove(P)

	if(ismob(grab))
		var/devour_timer = as_mob.client ? 50 SECONDS + rand(0, 20 SECONDS) : 3 MINUTES
		release_timer = addtimer(CALLBACK(src, .proc/release), devour_timer, TIMER_STOPPABLE)
		if(isliving(grab))
			var/mob/living/as_living = grab
			as_living.knock_down(360)
			as_living.blind_eyes(1)

	SEND_SIGNAL(grab, COMSIG_MOVABLE_DEVOURED, P)


	return COMSIG_GRAB_SUCCESSFUL_SELF_ATTACK

/datum/component/ability/devour/proc/can_devour_grabbed(atom/movable/AM)
	var/mob/P = parent
	if(!P.pulling)
		return FALSE
	if(P.pulling != AM)
		return FALSE
	if(ismob(AM))
		var/mob/M = AM
		if(M.buckled || M.stat == DEAD)
			return FALSE
	if(devoured)
		return FALSE
	return TRUE

/datum/component/ability/devour/proc/release(warning = FALSE)
	if(!devoured)
		return

	var/mob/P = parent
	P.visible_message("<span class='xenowarning'>\The [P] hurls out the contents of their stomach!</span>", \
		"<span class='xenowarning'>You hurl out the contents of your stomach!</span>", null, 5)
	
	devoured.forceMove(get_turf(P))
	SEND_SIGNAL(devoured, COMSIG_MOVABLE_RELEASED_FROM_STOMACH, parent)
	devoured = null
	if(release_timer)
		deltimer(release_timer)
	release_timer = null

	for(var/x in P.contents)
		var/atom/movable/stowaway = x
		stowaway.forceMove(get_turf(src))
		stack_trace("[stowaway] found in [P]'s contents. It shouldn't have ended there.")

	return COMSIG_KB_ACTIVATED

// Regurgitate
/datum/action/ability/regurgitate
	name = "Regurgitate"
	action_icon_state = "regurgitate"
	//mechanics_text = "Vomit whatever you have devoured."

/datum/action/ability/regurgitate/action_activate()
	SEND_SIGNAL(owner, COMSIG_XENOABILITY_REGURGITATE)
