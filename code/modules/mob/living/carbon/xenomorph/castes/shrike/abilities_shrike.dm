#define CALLING_BURROWED_DURATION 15 SECONDS

// ***************************************
// *********** Call of the Burrowed
// ***************************************
/datum/action/xeno_action/call_of_the_burrowed
	name = "Call of the Burrowed"
	action_icon_state = "lay_egg"
	cooldown_timer = 5 MINUTES
	keybind_signal = COMSIG_XENOABILITY_CALL_OF_THE_BURROWED


/datum/action/xeno_action/xeno_action/call_of_the_burrowed/action_activate()
	var/mob/living/carbon/xenomorph/shrike/S = owner
	S.calling_larvas = TRUE

	notify_ghosts("\The <b>[S]</b> is calling for the burrowed larvas to wake up!", source = S, NOTIFY_JOIN_AS_LARVA)

	addtimer(CALLBACK(S, /mob/living/carbon/xenomorph/shrike.proc/calling_larvas_end), CALLING_BURROWED_DURATION)

	add_cooldown()


/mob/living/carbon/xenomorph/shrike/proc/calling_larvas_end()
    calling_larvas = FALSE


// ***************************************
// *********** Psychic Fling
// ***************************************
/datum/action/xeno_action/psychic_fling
	name = "Psychic Fling"
	action_icon_state = "lay_egg"
	mechanics_text = "Knock a target flying up to 3 tiles. Ranged ability."
	cooldown_timer = 30 SECONDS
	plasma_cost = 100
	keybind_signal = COMSIG_XENOABILITY_PSYCHIC_FLING


/datum/action/xeno_action/activable/psychic_fling/on_cooldown_finish()
	to_chat(owner, "<span class='notice'>You gather enough mental strength to fling something again.</span>")
	return ..()


/datum/action/xeno_action/activable/psychic_fling/can_use_ability(atom/A, silent = FALSE, override_flags)
	. = ..()
	if(!.)
		return FALSE
	if(!A)
		return FALSE
	var/mob/living/carbon/xenomorph/shrike/S = owner
	var/max_dist = (S == S.hive.living_xeno_ruler) ? 6 : 3 //We can fling targets further away if we are the ruler.
	if(get_dist(S, A) > max_dist)
		return FALSE
	if(!ishuman(A))
		return FALSE
	var/mob/living/carbon/human/H = A
	if(H.stat == DEAD)
		return FALSE


/datum/action/xeno_action/activable/psychic_fling/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/carbon/human/H = A
	round_statistics.shrike_flings++

	X.visible_message("<span class='xenowarning'>\The [X] effortlessly flings [H] to the side!</span>", \
	"<span class='xenowarning'>You effortlessly fling [H] to the side!</span>")
	H.visible_message("<span class='xenowarning'>[H] is violently flung to the side by an unseen force!</span>", \
	"<span class='xenowarning'>You are violently flung to the side by an unseen force!</span>")
	playsound(H,'sound/weapons/alien_claw_block.ogg', 75, 1)
	succeed_activate()
	H.apply_effects(1, 2) 	// Stun
	shake_camera(H, 2, 1)

	var/facing = get_dir(X, H)
	var/fling_distance = 3
	var/turf/T = H.loc
	var/turf/temp

	for(var/x in 1 to fling_distance)
		temp = get_step(T, facing)
		if(!temp)
			break
		T = temp
	H.throw_at(T, fling_distance, 1, X, TRUE)

	add_cooldown()