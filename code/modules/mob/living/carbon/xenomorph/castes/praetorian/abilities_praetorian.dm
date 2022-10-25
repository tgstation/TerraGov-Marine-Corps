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
	if(!line_of_sight(owner, target, 3))
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
// *********** Acid dash
// ***************************************
/datum/action/xeno_action/activable/acid_dash
	name = "Acid Dash"
	action_icon_state = "charge"
	mechanics_text = "Instantly dash, tackling the first marine in your path. If you manage to tackle someone, gain another weaker cast of the ability."
	ability_name = "acid dash"
	plasma_cost = 250
	cooldown_timer = 30 SECONDS
	keybinding_signals = list(
		KEYBINDING_NORMAL = COMSIG_XENOABILITY_ACID_DASH,
	)
	///How far can we dash
	var/range = 5
	///Can we use the ability again
	var/recast_available = FALSE
	///Is this the recast
	var/recast = FALSE
	///The last tile we dashed through, used when swapping with a human
	var/turf/last_turf

/datum/action/xeno_action/activable/acid_dash/on_cooldown_finish()
	to_chat(owner, span_xenodanger("Our exoskeleton quivers as we get ready to use Acid Dash again."))
	playsound(owner, "sound/effects/xeno_newlarva.ogg", 50, 0, 1)
	return ..()

///Called when the dash is finished, handles cooldowns and recast. Clears signals too
/datum/action/xeno_action/activable/acid_dash/proc/dash_complete()
	var/mob/living/carbon/xenomorph/X = owner
	SIGNAL_HANDLER
	if(recast_available)
		addtimer(CALLBACK(src, .proc/dash_complete), 2 SECONDS) //Delayed recursive call, this time you won't gain a recast so it will go on cooldown in 2 SECONDS.
		recast = TRUE
	else
		recast = FALSE
		add_cooldown()

	X.reset_flags_pass()
	recast_available = FALSE
	UnregisterSignal(owner, list(COMSIG_XENO_OBJ_THROW_HIT, COMSIG_MOVABLE_POST_THROW, COMSIG_XENO_LIVING_THROW_HIT, COMSIG_MOVABLE_MOVED))

///Called whenever the owner hits a mob during the dash
/datum/action/xeno_action/activable/acid_dash/proc/mob_hit(datum/source, mob/M)
	SIGNAL_HANDLER
	if(recast || !ishuman(M)) //That's the recast, we don't stop for mobs
		return COMPONENT_KEEP_THROWING

	//Swapping part
	var/mob/living/carbon/human/target = M
	owner.flags_pass |= PASSMOB
	target.flags_pass |= PASSMOB
	INVOKE_ASYNC(src, /atom/movable/proc/forceMove, get_turf(target))
	INVOKE_ASYNC(target, /atom/movable/proc/forceMove, last_turf)
	if(!(owner.flags_pass & PASSMOB))
		owner.flags_pass &= ~PASSMOB
	if(!(target.flags_pass))
		target.flags_pass &= ~PASSMOB

	target.ParalyzeNoChain(0.5 SECONDS) //Extremely brief, we don't want them to take 289732 ticks of acid

	to_chat(target, span_highdanger("The [owner] tackles us, sending us behind them!"))
	owner.visible_message(span_xenodanger("\The [owner] tackles [target], swapping location with them!"), \
		span_xenodanger("We push [target] in our acid trail!"), visible_message_flags = COMBAT_MESSAGE)

	recast_available = TRUE

///Called whenever the owner hits an object during the dash
/datum/action/xeno_action/activable/acid_dash/proc/obj_hit(datum/source, obj/target, speed)
	SIGNAL_HANDLER
	if(!(istype(target, /obj/structure/table) || istype(target, /obj/structure/barricade) || istype(target, /obj/structure/razorwire)))
		target.hitby(owner, speed)
		return

	owner.visible_message(span_danger("[owner] effortlessly jumps over the [target]!"), null, null, 5) //Flavour only

///Drops an acid puddle on the current owner's tile, will do 0 damage if the owner has no acid_spray_damage
/datum/action/xeno_action/activable/acid_dash/proc/acid_steps(atom/A, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER
	last_turf = OldLoc
	var/mob/living/carbon/xenomorph/X = owner
	new /obj/effect/xenomorph/spray(get_turf(X), 5 SECONDS, X.xeno_caste.acid_spray_damage) //Add a modifier here to buff the damage if needed
	for(var/obj/O in get_turf(X))
		O.acid_spray_act(X)

/datum/action/xeno_action/activable/acid_dash/use_ability(atom/A)
	RegisterSignal(owner, COMSIG_XENO_OBJ_THROW_HIT, .proc/obj_hit)
	RegisterSignal(owner, COMSIG_XENO_LIVING_THROW_HIT, .proc/mob_hit)
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/acid_steps) //We drop acid on every tile we pass through
	RegisterSignal(owner, COMSIG_MOVABLE_POST_THROW, .proc/dash_complete)

	owner.visible_message(span_danger("[owner] slides towards \the [A]!"), \
	span_danger("We dash towards \the [A], spraying acid down our path!") )
	succeed_activate()

	owner.flags_pass = HOVERING
	owner.throw_at(A, range, 2, owner)

	return TRUE
