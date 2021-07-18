// ***************************************
// *********** Stomp
// ***************************************
/datum/action/xeno_action/activable/stomp
	name = "Stomp"
	action_icon_state = "stomp"
	mechanics_text = "Knocks all adjacent targets away and down."
	ability_name = "stomp"
	plasma_cost = 100
	cooldown_timer = 20 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_STOMP

/datum/action/xeno_action/activable/stomp/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	succeed_activate()
	add_cooldown()

	GLOB.round_statistics.crusher_stomps++
	SSblackbox.record_feedback("tally", "round_statistics", 1, "crusher_stomps")

	playsound(X.loc, 'sound/effects/bang.ogg', 25, 0)
	X.visible_message("<span class='xenodanger'>[X] smashes into the ground!</span>", \
	"<span class='xenodanger'>We smash into the ground!</span>")
	X.create_stomp() //Adds the visual effect. Wom wom wom

	for(var/mob/living/M in range(1, get_turf(X)))
		if(X.issamexenohive(M) || M.stat == DEAD || isnestedhost(M))
			continue
		var/distance = get_dist(M, X)
		var/damage = X.xeno_caste.stomp_damage/max(1, distance + 1)
		if(distance == 0) //If we're on top of our victim, give him the full impact
			GLOB.round_statistics.crusher_stomp_victims++
			SSblackbox.record_feedback("tally", "round_statistics", 1, "crusher_stomp_victims")
			M.take_overall_damage_armored(damage, BRUTE, "melee", FALSE, FALSE, TRUE)
			M.Paralyze(3 SECONDS)
			to_chat(M, "<span class='highdanger'>You are stomped on by [X]!</span>")
			shake_camera(M, 3, 3)
		else
			step_away(M, X, 1) //Knock away
			shake_camera(M, 2, 2)
			to_chat(M, "<span class='highdanger'>You reel from the shockwave of [X]'s stomp!</span>")
			M.take_overall_damage_armored(damage, BRUTE, "melee", FALSE, FALSE, TRUE) 
			M.Paralyze(0.5 SECONDS)

/datum/action/xeno_action/activable/stomp/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/stomp/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 1)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE

// ***************************************
// *********** Cresttoss
// ***************************************
/datum/action/xeno_action/activable/cresttoss
	name = "Crest Toss"
	action_icon_state = "cresttoss"
	mechanics_text = "Fling an adjacent target over and behind you. Also works over barricades."
	ability_name = "crest toss"
	plasma_cost = 75
	cooldown_timer = 12 SECONDS
	keybind_signal = COMSIG_XENOABILITY_CRESTTOSS
	target_flags = XABB_MOB_TARGET

/datum/action/xeno_action/activable/cresttoss/on_cooldown_finish()
	var/mob/living/carbon/xenomorph/X = owner
	to_chat(X, "<span class='xenowarning'><b>We can now crest toss again.</b></span>")
	playsound(X, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	return ..()

/datum/action/xeno_action/activable/cresttoss/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!owner.Adjacent(A) || !isliving(A))
		return FALSE
	var/mob/living/L = A
	if(L.stat == DEAD || isnestedhost(L)) //no bully
		return FALSE

/datum/action/xeno_action/activable/cresttoss/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/L = A
	X.face_atom(L) //Face towards the target so we don't look silly

	var/facing = get_dir(X, L)
	var/toss_distance = X.xeno_caste.crest_toss_distance
	var/turf/T = X.loc
	var/turf/temp = X.loc
	var/big_mob_message

	if(L.mob_size >= MOB_SIZE_BIG) //Penalize toss distance for big creatures
		toss_distance = FLOOR(toss_distance * 0.5, 1)
		big_mob_message = ", struggling mightily to heft its bulk"

	if(X.a_intent == INTENT_HARM) //If we use the ability on hurt intent, we throw them in front; otherwise we throw them behind.
		for(var/x in 1 to toss_distance)
			temp = get_step(T, facing)
			if (!temp)
				break
			T = temp
	else
		facing = get_dir(L, X)
		var/turf/throw_origin = get_step(T, facing)
		if(isclosedturf(throw_origin)) //Make sure the victim can actually go to the target turf
			to_chat(X, "<span class='xenowarning'>We try to fling [L] behind us, but there's no room!</span>")
			return fail_activate()
		for(var/obj/O in throw_origin)
			if(!O.CanPass(L, get_turf(X)) && !istype(O, /obj/structure/barricade)) //Ignore barricades because they will once thrown anyway
				to_chat(X, "<span class='xenowarning'>We try to fling [L] behind us, but there's no room!</span>")
				return fail_activate()

		L.forceMove(throw_origin) //Move the victim behind us before flinging
		for(var/x = 0, x < toss_distance, x++)
			temp = get_step(T, facing)
			if (!temp)
				break
			T = temp //Throw target

	//The target location deviates up to 1 tile in any direction //No.
	/*var/scatter_x = rand(-1,1)
	var/scatter_y = rand(-1,1)
	var/turf/new_target = locate(T.x + round(scatter_x),T.y + round(scatter_y),T.z) //Locate an adjacent turf.
	if(new_target)
		T = new_target//Looks like we found a turf.
	*/

	X.icon_state = "Crusher Charging"  //Momentarily lower the crest for visual effect

	X.visible_message("<span class='xenowarning'>\The [X] flings [L] away with its crest[big_mob_message]!</span>", \
	"<span class='xenowarning'>We fling [L] away with our crest[big_mob_message]!</span>")

	succeed_activate()

	L.throw_at(T, toss_distance, 1, X, TRUE)

	//Handle the damage
	if(!X.issamexenohive(L)) //Friendly xenos don't take damage.
		var/damage = toss_distance * 6

		L.take_overall_damage_armored(damage, BRUTE, "melee", updating_health = TRUE)
		shake_camera(L, 2, 2)
		playsound(L,pick('sound/weapons/alien_claw_block.ogg','sound/weapons/alien_bite2.ogg'), 50, 1)

	add_cooldown()
	addtimer(CALLBACK(X, /mob/.proc/update_icons), 3)

/datum/action/xeno_action/activable/cresttoss/ai_should_start_consider()
	return TRUE

/datum/action/xeno_action/activable/cresttoss/ai_should_use(target)
	if(!iscarbon(target))
		return ..()
	if(get_dist(target, owner) > 1)
		return ..()
	if(!can_use_ability(target, override_flags = XACT_IGNORE_SELECTED_ABILITY))
		return ..()
	return TRUE
