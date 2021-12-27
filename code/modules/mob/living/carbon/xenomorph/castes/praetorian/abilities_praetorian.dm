// ***************************************
// *********** Acid spray
// ***************************************
/datum/action/xeno_action/activable/spray_acid/cone
	name = "Spray Acid Cone"
	action_icon_state = "spray_acid"
	mechanics_text = "Spray a cone of dangerous acid at your target."
	ability_name = "spray acid"
	plasma_cost = 300
	cooldown_timer = 40 SECONDS

/datum/action/xeno_action/activable/spray_acid/cone/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/turf/target = get_turf(A)

	if(!istype(target)) //Something went horribly wrong. Clicked off edge of map probably
		return

	if(!do_after(X, 5, TRUE, target, BUSY_ICON_DANGER))
		return fail_activate()

	if(!can_use_ability(A, TRUE, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return fail_activate()

	GLOB.round_statistics.praetorian_acid_sprays++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "praetorian_acid_sprays")

	succeed_activate()

	playsound(X.loc, 'sound/effects/refill.ogg', 25, 1)
	X.visible_message(span_xenowarning("\The [X] spews forth a wide cone of acid!"), \
	span_xenowarning("We spew forth a cone of acid!"), null, 5)

	X.add_movespeed_modifier(type, TRUE, 0, NONE, TRUE, 1)
	start_acid_spray_cone(target, X.xeno_caste.acid_spray_range)
	add_cooldown()
	addtimer(CALLBACK(src, .proc/reset_speed), rand(2 SECONDS, 3 SECONDS))

/datum/action/xeno_action/activable/spray_acid/cone/proc/reset_speed()
	var/mob/living/carbon/xenomorph/spraying_xeno = owner
	if(QDELETED(spraying_xeno))
		return
	spraying_xeno.remove_movespeed_modifier(type)

/datum/action/xeno_action/activable/spray_acid/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/spray_acid/ai_should_use(atom/target)
	if(owner.do_actions) //Chances are we're already spraying acid, don't override it
		return FALSE
	if(!iscarbon(target))
		return FALSE
	if(get_dist(target, owner) > 3)
		return FALSE
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return FALSE
	if(target.get_xeno_hivenumber() == owner.get_xeno_hivenumber())
		return FALSE
	return TRUE

GLOBAL_LIST_INIT(acid_spray_hit, typecacheof(list(/obj/structure/barricade, /obj/vehicle/multitile/root/cm_armored, /obj/structure/razorwire)))

#define CONE_PART_MIDDLE (1<<0)
#define CONE_PART_LEFT (1<<1)
#define CONE_PART_RIGHT (1<<2)
#define CONE_PART_DIAG_LEFT (1<<3)
#define CONE_PART_DIAG_RIGHT (1<<4)
#define CONE_PART_MIDDLE_DIAG (1<<5)

///Start the acid cone spray in the correct direction
/datum/action/xeno_action/activable/spray_acid/cone/proc/start_acid_spray_cone(turf/T, range)
	var/facing = angle_to_dir(Get_Angle(owner, T))
	owner.setDir(facing)
	switch(facing)
		if(NORTH, SOUTH, EAST, WEST)
			do_acid_cone_spray(owner.loc, range, facing, CONE_PART_MIDDLE|CONE_PART_LEFT|CONE_PART_RIGHT, owner, TRUE)
		if(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			do_acid_cone_spray(owner.loc, range, facing, CONE_PART_MIDDLE_DIAG, owner, TRUE)
			do_acid_cone_spray(owner.loc, range + 1, facing, CONE_PART_DIAG_LEFT|CONE_PART_DIAG_RIGHT, owner, TRUE)

///Check if it's possible to create a spray, and if yes, check if the spray must continue
/datum/action/xeno_action/activable/spray_acid/cone/proc/do_acid_cone_spray(turf/T, distance_left, facing, direction_flag, source_spray, skip_timer = FALSE)
	if(distance_left <= 0)
		return
	if(T.density)
		return
	var/is_blocked = FALSE
	for (var/obj/O in T)
		if(is_type_in_typecache(O, GLOB.acid_spray_hit))
			O.acid_spray_act(owner)
		if(!O.CanPass(source_spray, get_turf(source_spray)))
			is_blocked = TRUE
	if(is_blocked)
		return

	var/mob/living/carbon/xenomorph/praetorian/xeno_owner = owner

	var/obj/effect/xenomorph/spray/spray = new(T, xeno_owner.xeno_caste.acid_spray_duration, xeno_owner.xeno_caste.acid_spray_damage, xeno_owner)
	var/turf/next_normal_turf = get_step(T, facing)
	for (var/atom/movable/A AS in T)
		A.acid_spray_act(owner)
		if(((A.density && !A.throwpass && !(A.flags_atom & ON_BORDER)) || !A.Exit(source_spray, facing)) && !isxeno(A))
			is_blocked = TRUE
	if(!is_blocked)
		if(!skip_timer)
			addtimer(CALLBACK(src, .proc/continue_acid_cone_spray, T, next_normal_turf, distance_left, facing, direction_flag, spray), 3)
			return
		continue_acid_cone_spray(T, next_normal_turf, distance_left, facing, direction_flag, spray)


///Call the next steps of the cone spray,
/datum/action/xeno_action/activable/spray_acid/cone/proc/continue_acid_cone_spray(turf/current_turf, turf/next_normal_turf, distance_left, facing, direction_flag, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_MIDDLE))
		do_acid_cone_spray(next_normal_turf, distance_left - 1 , facing, CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_RIGHT))
		do_acid_cone_spray(get_step(next_normal_turf, turn(facing, 90)), distance_left - 1, facing, CONE_PART_RIGHT|CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_LEFT))
		do_acid_cone_spray(get_step(next_normal_turf, turn(facing, -90)), distance_left - 1, facing, CONE_PART_LEFT|CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_DIAG_LEFT))
		do_acid_cone_spray(get_step(current_turf, turn(facing, 45)), distance_left - 1, turn(facing, 45), CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_DIAG_RIGHT))
		do_acid_cone_spray(get_step(current_turf, turn(facing, -45)), distance_left - 1, turn(facing, -45), CONE_PART_MIDDLE, spray)
	if(CHECK_BITFIELD(direction_flag, CONE_PART_MIDDLE_DIAG))
		do_acid_cone_spray(next_normal_turf, distance_left - 1, facing, CONE_PART_DIAG_LEFT|CONE_PART_DIAG_RIGHT, spray)
		do_acid_cone_spray(next_normal_turf, distance_left - 2, facing, (distance_left < 5) ? CONE_PART_MIDDLE : CONE_PART_MIDDLE_DIAG, spray)

// ***************************************
// *********** Tail sweep
// ***************************************
/datum/action/xeno_action/activable/tail_sweep
	name = "Tail Sweep"
	action_icon_state = "tail_sweep"
	mechanics_text = "Hit all adjacent units around you, knocking them away. Highly recommend for self-defense against point-blank!"
	ability_name = "tail sweep"
	plasma_cost = 35
	cooldown_timer = 12 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_TAIL_SWEEP

/datum/action/xeno_action/activable/tail_sweep/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/X = owner
	if(X.crest_defense && X.plasma_stored < (plasma_cost * 2))
		if(!silent)
			to_chat(X, "<span class='xenowarning'>We don't have enough plasma, we need [(plasma_cost * 2) - X.plasma_stored] more plasma!</span>")
		return FALSE

/datum/action/xeno_action/activable/tail_sweep/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, "<span class='notice'>We gather enough strength to tail sweep again.</span>")
	return ..()

/datum/action/xeno_action/activable/tail_sweep/use_ability()
	var/mob/living/carbon/xenomorph/X = owner

	GLOB.round_statistics.defender_tail_sweeps++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "defender_tail_sweeps")
	X.visible_message("<span class='xenowarning'>\The [X] sweeps its tail in a wide circle!</span>", \
	"<span class='xenowarning'>We sweep our tail in a wide circle!</span>")

	X.spin(4, 1)

	var/sweep_range = 1
	var/list/L = orange(sweep_range, X)		// Not actually the fruit

	for (var/mob/living/carbon/human/H in L)
		step_away(H, src, sweep_range, 2)
		if(H.stat != DEAD && !isnestedhost(H) ) //No bully
			var/damage = X.xeno_caste.melee_damage
			var/affecting = H.get_limb(ran_zone(null, 0))
			if(!affecting) //Still nothing??
				affecting = H.get_limb("chest") //Gotta have a torso?!
			var/armor_block = H.run_armor_check(affecting, "melee")
			H.apply_damage(damage, BRUTE, affecting, armor_block) //Crap base damage after armour...
			H.apply_damage(damage, STAMINA) //...But some sweet armour ignoring Stamina
			UPDATEHEALTH(H)
			step_away(H, X, sweep_range, 1)
		GLOB.round_statistics.defender_tail_sweep_hits++
		SSblackbox.record_feedback("tally", "round_statistics", 1, "tail_sweep_hits")
		shake_camera(H, 2, 1)

		to_chat(H, "<span class='xenowarning'>We are struck by \the [X]'s tail sweep!</span>")
		playsound(H,'sound/weapons/alien_claw_block.ogg', 50, 1)

	succeed_activate()
	add_cooldown()

/datum/action/xeno_action/activable/tail_sweep/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 1)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE
