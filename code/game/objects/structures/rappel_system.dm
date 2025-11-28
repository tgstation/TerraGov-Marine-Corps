//////////////// RAPPEL SYSTEM /////////////////

//Rappel defines
#define RAPPEL_REPAIR_TIME 10 MINUTES

#define RAPPEL_CONDITION_DAMAGED 0
#define RAPPEL_CONDITION_DISABLED 1
#define RAPPEL_CONDITION_HOOKED 2
#define RAPPEL_CONDITION_GOOD 3

#define RAPPEL_STATE_LOCKED 0
#define RAPPEL_STATE_RETRACTING 1
#define RAPPEL_STATE_USABLE 2
#define RAPPEL_STATE_IN_USE 3

//Rappel target selection action
/datum/action/innate/rappel_designate
	name = "Designate rappel point"
	action_icon = 'icons/mob/actions/actions_mecha.dmi'
	action_icon_state = "mech_zoom_on"
	var/obj/structure/dropship_equipment/shuttle/rappel_system/origin

/datum/action/innate/rappel_designate/Activate()
	if(origin.rappel_state == RAPPEL_STATE_RETRACTING) //We're already retracting a rope!
		return

	var/mob/C = target
	var/mob/camera/aiEye/remote/remote_eye = C.remote_control
	var/turf/target_turf = get_turf(remote_eye)
	var/area/target_area = get_area(target_turf)
	if(origin.rappel_condition < RAPPEL_CONDITION_GOOD || target_turf.density || target_area.ceiling > CEILING_GLASS)
		playsound(origin, 'sound/machines/buzz-two.ogg', 25)
		return

	C.playsound_local(origin, 'sound/effects/binoctarget.ogg', 35)

	if(origin.rappel_state >= RAPPEL_STATE_USABLE)
		origin.pre_retract()
		return

	if(!do_after(C, 5 SECONDS, NONE, remote_eye, BUSY_ICON_BAR) || origin.rappel_condition < RAPPEL_CONDITION_GOOD || origin.rappel_state > RAPPEL_STATE_LOCKED || target_turf.density)
		return

	origin.deploy_rope(target_turf)
	playsound(origin, 'sound/machines/chime.ogg', 50, FALSE)

//The actual system you put on the tadpole
/obj/structure/dropship_equipment/shuttle/rappel_system
	equip_category = DROPSHIP_CREW_WEAPON
	name = "rappel deployment system"
	desc = "A system that deploys rappel ropes to go up or down fast, without the need for the Tadpole to land. You need to designate the rappel point at the navigation computer."
	dropship_equipment_flags = IS_INTERACTABLE
	icon_state = "rappel_hatch_locked"

	point_cost = 100
	max_integrity = 300
	anchored = TRUE
	density = FALSE
	///The rappeling rope we use
	var/obj/effect/rappel_rope/tadpole/rope
	///Smoke particle holder for when it's disabled
	var/obj/effect/abstract/particle_holder/disabled_smoke
	///What state the rope is in (usable, hooked, locked, in-use, etc.)
	var/rappel_state = RAPPEL_STATE_LOCKED
	//What condition the rope is in (good, needs cord replacing, self-repairing, etc.)
	var/rappel_condition = RAPPEL_CONDITION_GOOD

/obj/structure/dropship_equipment/shuttle/rappel_system/Initialize(mapload)
	. = ..()
	rope = new(src)

/obj/structure/dropship_equipment/shuttle/rappel_system/Destroy()
	. = ..()
	QDEL_NULL(rope)

/obj/structure/dropship_equipment/shuttle/rappel_system/update_icon_state()
	. = ..()
	if(rappel_condition <= RAPPEL_CONDITION_DISABLED)
		icon_state = "rappel_hatch_disabled"
		return

	switch(rappel_state)
		if(RAPPEL_STATE_USABLE)
			icon_state = "rappel_hatch_unlocked"
		if(RAPPEL_STATE_IN_USE)
			icon_state = "rappel_hatch_open"
		else
			icon_state = "rappel_hatch_locked"

/obj/structure/dropship_equipment/shuttle/rappel_system/examine(mob/user)
	. = ..()
	switch(rappel_condition)
		if(RAPPEL_CONDITION_GOOD)
			. += "It's in good condition."
		if(RAPPEL_CONDITION_DISABLED)
			. += "The rappel's cord has been replaced, but the system is still smoking. It'll take some time for its self-repair function to kick in."
		if(RAPPEL_CONDITION_DAMAGED)
			. += "The rappel's cord is completely broken and needs replacing."

//Human interaction with the rappel system; this is how people rappel down
/obj/structure/dropship_equipment/shuttle/rappel_system/attack_hand(mob/living/carbon/human/user)
	if(!rope)
		to_chat(user, span_userdanger("\The [src]'s rope does not exist. Adminhelp this."))
		attack_rappel() //If rope can't be found, default to a visibly broken state

	switch(rappel_condition)
		if(RAPPEL_CONDITION_DAMAGED)
			balloon_alert(user, "the cord needs replacing!")
			return
		if(RAPPEL_CONDITION_DISABLED)
			balloon_alert(user, "the system is disabled!")
			return

	var/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/linked_dropship = linked_shuttle?.shuttle_computer
	if(linked_dropship?.fly_state != SHUTTLE_IN_ATMOSPHERE)
		balloon_alert(user, "not in-flight!")
		return

	switch(rappel_state)
		if(RAPPEL_STATE_LOCKED)
			balloon_alert(user, "no rappel deployed!")
			return
		if(RAPPEL_STATE_RETRACTING)
			balloon_alert(user, "rappel retracting!")
			return

	var/turf/target_turf = get_turf(rope)
	if(target_turf.density)
		balloon_alert(user, "that's a wall!")
		return

	var/area/target_area = get_area(target_turf)
	if(target_area.ceiling > CEILING_GLASS)
		balloon_alert(user, "too deep underground!")
		return

	rappel_state = RAPPEL_STATE_IN_USE
	rope.update_icon_state()
	update_icon_state()
	flick("rappel_hatch_opening", src)

	user.reset_perspective(target_turf)

	var/passed_skillcheck = TRUE
	if(user.skills.getRating(SKILL_COMBAT) < SKILL_COMBAT_DEFAULT)
		rope.balloon_alert(user, "you fumble around figuring out how to use the rappel system...")
		if(!do_after(user, 3 SECONDS, NONE, rope, BUSY_ICON_UNSKILLED) && !user.lying_angle && !user.anchored && rappel_state >= RAPPEL_STATE_USABLE && rappel_condition == RAPPEL_CONDITION_GOOD)
			passed_skillcheck = FALSE

	if(passed_skillcheck && do_after(user, 4 SECONDS, NONE, rope, BUSY_ICON_GENERIC) && !user.lying_angle && !user.anchored && rappel_state >= RAPPEL_STATE_USABLE && rappel_condition == RAPPEL_CONDITION_GOOD)
		playsound(target_turf, 'sound/effects/rappel.ogg', 50, TRUE)
		playsound(src, 'sound/effects/rappel.ogg', 50, TRUE)
		user.forceMove(target_turf)
		rappel_animation(user)
		var/turf/target_floor = get_turf(rope)
		if(istype(target_floor, /turf/open/floor))
			target_floor.ceiling_debris_check(2)

	flick("rappel_hatch_closing", src)
	rappel_state = RAPPEL_STATE_USABLE
	update_icon_state()
	rope.update_icon_state()

	user.reset_perspective()

/obj/structure/dropship_equipment/shuttle/rappel_system/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(istype(I, /obj/item/powerloader_clamp))
		return

	if(istype(I, /obj/item/spare_cord))
		if(rappel_condition != RAPPEL_CONDITION_DAMAGED)
			balloon_alert(user, "the cord isn't damaged!")
			return
		balloon_alert(user, "replacing the rappel cord...")
		if(!do_after(user, 2 SECONDS, NONE, src, BUSY_ICON_GENERIC))
			return
		if(!rope) //If the rappel is bugged, fix it
			rope = new(src)
		rappel_condition = RAPPEL_CONDITION_DISABLED
		update_icon_state()
		addtimer(CALLBACK(src, PROC_REF(self_repair)), RAPPEL_REPAIR_TIME)
		balloon_alert(user, "replaced")
		QDEL_NULL(I)
		return

	attack_hand(user) //If the player's using anything else, drop them down

//Ghosts instantly teleport to wherever the rope is
/obj/structure/dropship_equipment/shuttle/rappel_system/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(rappel_state == RAPPEL_STATE_USABLE)
		user.forceMove(get_turf(rope))

///Disabled rappels repair themselves after the cord is placed back in.
/obj/structure/dropship_equipment/shuttle/rappel_system/proc/self_repair()
	rappel_condition = RAPPEL_CONDITION_GOOD
	if(disabled_smoke)
		QDEL_NULL(disabled_smoke)
	update_icon_state()
	balloon_alert_to_viewers("pings happily—self repair complete")
	playsound(src, 'sound/machines/ping.ogg', 50, FALSE)

///Human animation for dropping down
/obj/structure/dropship_equipment/shuttle/rappel_system/proc/rappel_animation(mob/living/user)
	var/pre_rappel_alpha = user.alpha
	user.alpha = 20
	user.dir = WEST
	user.canmove = FALSE
	var/matrix/initial_matrix = user.transform
	initial_matrix.Turn(45)
	user.pixel_y = 8
	var/matrix/reset_matrix = user.transform
	animate(user, 3, transform = reset_matrix, pixel_y = 0, alpha = pre_rappel_alpha, flags = ANIMATION_PARALLEL)
	user.canmove = TRUE

///Deploys the rappel and unlocks the hatch so that people can drop down
/obj/structure/dropship_equipment/shuttle/rappel_system/proc/deploy_rope(turf/target)
	if(!rope || rappel_condition < RAPPEL_CONDITION_GOOD || rappel_state >= RAPPEL_STATE_USABLE)
		return
	var/obj/machinery/computer/camera_advanced/shuttle_docker/minidropship/linked_dropship = linked_shuttle?.shuttle_computer
	if(linked_dropship?.fly_state != SHUTTLE_IN_ATMOSPHERE)
		return

	rope.forceMove(target)
	rappel_state = RAPPEL_STATE_USABLE
	update_icon_state()
	rope.update_icon_state()
	flick("rope_deploy", rope)
	SSminimaps.add_marker(rope, MINIMAP_FLAG_MARINE, image('icons/UI_icons/map_blips.dmi', null, "rappel", MINIMAP_BLIPS_LAYER))
	var/area/rappel_area = get_area(target)
	if(!(rappel_area.area_flags & MARINE_BASE))
		SEND_GLOBAL_SIGNAL(COMSIG_GLOB_TADPOLE_RAPPEL_DEPLOYED_OUT_LZ)

	playsound(target, 'sound/effects/tadpolehovering.ogg', 100, TRUE, falloff = 2.5)
	playsound(target, 'sound/effects/rappel.ogg', 50, TRUE)
	playsound(src, 'sound/effects/rappel.ogg', 50, TRUE)
	target.balloon_alert_to_viewers("!!!")
	target.visible_message(span_userdanger("You see a dropship fly overhead and begin dropping ropes!"))
	balloon_alert_to_viewers("hisses and unlocks!")

///Feedback for when PO manually retracts the rope. Leads back into retract_rope after sounds and balloon alerts are done.
/obj/structure/dropship_equipment/shuttle/rappel_system/proc/pre_retract()
	if(rappel_state == RAPPEL_STATE_RETRACTING) //We're already retracting!
		return

	rappel_state = RAPPEL_STATE_RETRACTING
	update_icon_state()
	rope.update_icon_state()

	playsound(src, 'sound/machines/hiss.ogg', 25)
	balloon_alert_to_viewers("hums as the rope reels in")
	rope.balloon_alert_to_viewers("starts reeling up...")

	addtimer(CALLBACK(src, PROC_REF(retract_rope)), 5 SECONDS)


///Undeploys the rappel and locks the hatch. Rappel cannot be retracted if it is currently being attacked (hooked)
/obj/structure/dropship_equipment/shuttle/rappel_system/proc/retract_rope()
	if(rappel_state != RAPPEL_STATE_RETRACTING)
		return

	if(rappel_condition == RAPPEL_CONDITION_HOOKED)
		rappel_state = RAPPEL_STATE_USABLE
		playsound(src, 'sound/machines/buzz-sigh.ogg', 25)
		return

	rappel_state = RAPPEL_STATE_LOCKED
	update_icon_state()
	var/turf/target = get_turf(rope)
	target.balloon_alert_to_viewers("retracted")
	balloon_alert_to_viewers("clicks locked as the ropes reel back")
	playsound(target, 'sound/effects/tadpolehovering.ogg', 100, TRUE, falloff = 2.5)
	playsound(target, 'sound/effects/rappel.ogg', 50, TRUE)
	playsound(src, 'sound/effects/rappel.ogg', 50, TRUE)
	flick("rope_up", rope)

	addtimer(CALLBACK(src, PROC_REF(reel_in)), 0.4 SECONDS)

///Part 2 of retract_rope(), moves the rope back into the system after the rope animation has completed. Unbuckles any mobs which were attached to it.
/obj/structure/dropship_equipment/shuttle/rappel_system/proc/reel_in()
	rope.forceMove(src)
	SSminimaps.remove_marker(rope)

//When tad leaves, disable active rappels
/obj/structure/dropship_equipment/shuttle/rappel_system/on_launch()
	if(rappel_condition == RAPPEL_CONDITION_HOOKED) //Tadpole is moving with ropes hooked, so the ropes will snap
		var/turf/target_floor = get_turf(rope)
		target_floor.balloon_alert_to_viewers("the rope is ripped out from above!")
		balloon_alert_to_viewers("the rope is ripped out from under!")
		break_rappel()
		return

	if(rappel_state >= RAPPEL_STATE_USABLE) //Otherwise, tadpole retracts rappels normally
		pre_retract()

///Handles xeno attacks on the system; called by the rappel rope whenever attack_alien() is called on the rope
/obj/structure/dropship_equipment/shuttle/rappel_system/proc/attack_rappel(mob/living/carbon/xenomorph/attacker)
	//Stops the pilot bringing up the rappel to prevent it being disabled
	rappel_condition = RAPPEL_CONDITION_HOOKED
	var/previously_retracting = FALSE //Lets us continue retracting the rope if it was previously
	if(rappel_state == RAPPEL_STATE_RETRACTING)
		rappel_state = RAPPEL_STATE_USABLE
		previously_retracting = TRUE
	update_icon_state()
	attacker.balloon_alert(attacker, "disabling the sky-rope system...")
	step(attacker, get_dir(attacker, rope))
	balloon_alert_to_viewers("the system is visibly buckling!")
	playsound(rope, 'sound/effects/grillehit.ogg', 50, TRUE)
	playsound(src, 'sound/effects/grillehit.ogg', 50, TRUE)
	Shake(duration = 2.5 SECONDS)
	if(!do_after(attacker, 5 SECONDS, NONE, rope, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
		rappel_condition = RAPPEL_CONDITION_GOOD
		rappel_state = RAPPEL_STATE_USABLE
		update_icon_state()
		balloon_alert_to_viewers("the system stops buckling...")
		if(previously_retracting)
			pre_retract()
		return

	attacker.balloon_alert_to_viewers("rappel cord ripped out!", "sky-rope disabled")
	visible_message(span_boldwarning("You hear a horrible screeching sound as something under \the [src] breaks!"))
	break_rappel()

///Disables the rappel system, retracting any active ropes in the process.
/obj/structure/dropship_equipment/shuttle/rappel_system/proc/break_rappel()
	if(rappel_condition <= RAPPEL_CONDITION_DISABLED) //Already broken!
		return
	rappel_condition = RAPPEL_CONDITION_DAMAGED
	rappel_state = RAPPEL_STATE_RETRACTING

	playsound(rope, 'sound/effects/metal_crash.ogg', 50, TRUE)
	playsound(rope, 'sound/effects/sparks1.ogg', 50, TRUE)
	playsound(src, 'sound/effects/metal_crash.ogg', 50, TRUE)
	playsound(src, 'sound/effects/creak1.ogg', 50, TRUE)

	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(5, 0, src)
	sparks.attach(src)
	sparks.start()
	sparks.attach(rope)
	sparks.start()

	if(!disabled_smoke)
		disabled_smoke = new(src, /particles/mecha_smoke)
		disabled_smoke.particles.position = list(0,5,0)

	update_icon_state()
	retract_rope()

///This is the rope that the system deploys, a subtype of the HvH deployment rappel.
///Created by the rappel system on init and stored in the rappel system when it's not in use
/obj/effect/rappel_rope/tadpole
	icon = 'icons/obj/structures/prop/mainship.dmi'
	name = "tadpole rappel rope"
	light_system = STATIC_LIGHT
	light_power = 0.5
	light_range = 2
	resistance_flags = RESIST_ALL | PROJECTILE_IMMUNE | DROPSHIP_IMMUNE //Things might implode if we allow these
	///The rappel system this rope originates from
	var/obj/structure/dropship_equipment/shuttle/rappel_system/parent_system

/obj/effect/rappel_rope/tadpole/Initialize(mapload)
	. = ..()
	if(istype(loc, /obj/structure/dropship_equipment/shuttle/rappel_system))
		parent_system = loc

/obj/effect/rappel_rope/tadpole/Destroy()
	. = ..()
	parent_system?.rope = null //Clean refs

/obj/effect/rappel_rope/tadpole/update_icon_state()
	. = ..()
	if(parent_system.rappel_state == RAPPEL_STATE_IN_USE || parent_system.rappel_state == RAPPEL_STATE_RETRACTING)
		icon_state = "rope_rappeling"
		return
	icon_state = "rope"

//Going up the rappel. Going up retracts the rappel
/obj/effect/rappel_rope/tadpole/attack_hand(mob/living/user)
	. = ..()

	if(parent_system.rappel_condition < RAPPEL_CONDITION_GOOD)
		return

	if(LinkBlocked(get_turf(user), get_turf(src)))
		user.balloon_alert(user, "blocked!")
		return
	user.balloon_alert(user, "clipping...")

	if(user.skills.getRating(SKILL_COMBAT) < SKILL_COMBAT_DEFAULT)
		if(!do_after(user, 3 SECONDS, NONE, src, BUSY_ICON_UNSKILLED) || user.lying_angle || user.anchored)
			return

	if(!do_after(user, 8 SECONDS * (1 + length(user.buckled_mobs)), NONE, src, BUSY_ICON_GENERIC) || user.lying_angle || user.anchored)
		return
	user.forceMove(get_turf(parent_system))

	playsound(get_turf(src), 'sound/effects/rappel.ogg', 50, TRUE)

//Ghosts teleport to the rappel system when they click on the rope
/obj/effect/rappel_rope/tadpole/attack_ghost(mob/dead/observer/user)
	. = ..()
	user.forceMove(get_turf(parent_system))

//Rappel destruction, xeno mains rejoice
/obj/effect/rappel_rope/tadpole/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	. = ..()
	parent_system.attack_rappel(X)

///Replacement rappel cord, necessary to fully repair a damaged rappel system
/obj/item/spare_cord
	name = "replacement rappel cord box"
	desc = "A box full of expensive, plasteel-infused spare rappel cord for a rappel system. Click on a rappel system to replace any damaged cord, making the system functional again."
	icon = 'icons/obj/structures/prop/mainship.dmi'
	icon_state = "cordbox"
	w_class = WEIGHT_CLASS_BULKY
