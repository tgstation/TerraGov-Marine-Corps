// ***************************************
// *********** Stomp
// ***************************************
/datum/action/xeno_action/activable/stomp
	name = "Stomp (50)"
	action_icon_state = "stomp"
	mechanics_text = "Knocks all adjacent targets away and down."
	ability_name = "stomp"

/datum/action/xeno_action/activable/stomp/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/Crusher/X = owner
	if(world.time >= X.has_screeched + CRUSHER_STOMP_COOLDOWN)
		return TRUE

/datum/action/xeno_action/activable/stomp/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/Crusher/X = owner
	X.stomp()

/mob/living/carbon/Xenomorph/Crusher/proc/stomp()

	if(!check_state()) return

	if(world.time < has_screeched + CRUSHER_STOMP_COOLDOWN) //Sure, let's use this.
		to_chat(src, "<span class='xenowarning'>You are not ready to stomp again.</span>")
		return FALSE

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't rear up to stomp with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to stomp but are unable as you fail to shake off the shock!</span>")
		return

	if(!check_plasma(80))
		return
	has_screeched = world.time
	use_plasma(80)

	round_statistics.crusher_stomps++

	playsound(loc, 'sound/effects/bang.ogg', 25, 0)
	visible_message("<span class='xenodanger'>[src] smashes into the ground!</span>", \
	"<span class='xenodanger'>You smash into the ground!</span>")
	create_stomp() //Adds the visual effect. Wom wom wom

	for(var/mob/living/M in range(2,loc))
		if(isxeno(M) || M.stat == DEAD || ((M.status_flags & XENO_HOST) && istype(M.buckled, /obj/structure/bed/nest)))
			continue
		var/distance = get_dist(M, loc)
		var/damage = (rand(CRUSHER_STOMP_LOWER_DMG, CRUSHER_STOMP_UPPER_DMG) * CRUSHER_STOMP_UPGRADE_BONUS) / max(1,distance + 1)
		if(frenzy_aura > 0)
			damage *= (1 + round(frenzy_aura * 0.1,0.01)) //+10% per level of Frenzy
		if(distance == 0) //If we're on top of our victim, give him the full impact
			round_statistics.crusher_stomp_victims++
			var/armor_block = M.run_armor_check("chest", "melee") * 0.5 //Only 50% armor applies vs stomp brute damage
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.take_overall_damage(damage, null, 0, 0, 0, armor_block) //Armour functions against this.
			else
				M.take_overall_damage(damage, 0, null, armor_block) //Armour functions against this.
			to_chat(M, "<span class='highdanger'>You are stomped on by [src]!</span>")
			shake_camera(M, 3, 3)
		else
			step_away(M, src, 1) //Knock away
			shake_camera(M, 2, 2)
			to_chat(M, "<span class='highdanger'>You reel from the shockwave of [src]'s stomp!</span>")
		if(distance < 2) //If we're beside or adjacent to the Crusher, we get knocked down.
			M.KnockDown(1)
		else
			M.Stun(1) //Otherwise we just get stunned.
		M.apply_damage(damage, HALLOSS) //Armour ignoring Halloss

// ***************************************
// *********** Charge
// ***************************************
/datum/action/xeno_action/ready_charge
	name = "Toggle Charging"
	action_icon_state = "ready_charge"
	mechanics_text = "Toggles the Crusher’s movement based charge on and off."
	plasma_cost = 0

/datum/action/xeno_action/ready_charge/action_activate()
	var/mob/living/carbon/Xenomorph/X = owner
	if(!X.check_state()) return FALSE
	if(X.legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't charge with that thing on your leg!</span>")
		X.is_charging = 0
	else
		X.is_charging = !X.is_charging
		to_chat(X, "<span class='xenonotice'>You will [X.is_charging ? "now" : "no longer"] charge when moving.</span>")

// ***************************************
// *********** Cresttoss
// ***************************************
/datum/action/xeno_action/activable/cresttoss
	name = "Crest Toss"
	action_icon_state = "cresttoss"
	mechanics_text = "Fling an adjacent target over and behind you. Also works over barricades."
	ability_name = "crest toss"

/datum/action/xeno_action/activable/cresttoss/use_ability(atom/A)
	var/mob/living/carbon/Xenomorph/X = owner
	X.cresttoss(A)

/datum/action/xeno_action/activable/cresttoss/action_cooldown_check()
	var/mob/living/carbon/Xenomorph/X = owner
	return !X.cresttoss_used

/mob/living/carbon/Xenomorph/proc/cresttoss(var/mob/living/carbon/M)
	if(cresttoss_used)
		return

	if(!check_plasma(CRUSHER_CRESTTOSS_COST))
		return

	if(legcuffed)
		to_chat(src, "<span class='xenodanger'>You can't maneuver your body properly with that thing on your leg!</span>")
		return

	if(stagger)
		to_chat(src, "<span class='xenowarning'>You try to fling away [M] but are too disoriented!</span>")
		return

	if (!Adjacent(M) || !isliving(M)) //Sanity check
		return

	if(M.stat == DEAD || (M.status_flags & XENO_HOST && istype(M.buckled, /obj/structure/bed/nest) ) ) //no bully
		return

	if(M.mob_size >= MOB_SIZE_BIG) //We can't fling big aliens/mobs
		to_chat(src, "<span class='xenowarning'>[M] is too large to fling!</span>")
		return

	face_atom(M) //Face towards the target so we don't look silly

	var/facing = get_dir(src, M)
	var/toss_distance = rand(3,5)
	var/turf/T = loc
	var/turf/temp = loc
	if(a_intent == INTENT_HARM) //If we use the ability on hurt intent, we throw them in front; otherwise we throw them behind.
		for (var/x in 1 to toss_distance)
			temp = get_step(T, facing)
			if (!temp)
				break
			T = temp
	else
		facing = get_dir(M, src)
		if(!check_blocked_turf(get_step(T, facing) ) ) //Make sure we can actually go to the target turf
			M.loc = get_step(T, facing) //Move the target behind us before flinging
			for (var/x = 0, x < toss_distance, x++)
				temp = get_step(T, facing)
				if (!temp)
					break
				T = temp
		else
			to_chat(src, "<span class='xenowarning'>You try to fling [M] behind you, but there's no room!</span>")
			return

	//The target location deviates up to 1 tile in any direction
	var/scatter_x = rand(-1,1)
	var/scatter_y = rand(-1,1)
	var/turf/new_target = locate(T.x + round(scatter_x),T.y + round(scatter_y),T.z) //Locate an adjacent turf.
	if(new_target)
		T = new_target//Looks like we found a turf.

	icon_state = "Crusher Charging"  //Momentarily lower the crest for visual effect

	visible_message("<span class='xenowarning'>\The [src] flings [M] away with its crest!</span>", \
	"<span class='xenowarning'>You fling [M] away with your crest!</span>")

	cresttoss_used = TRUE
	use_plasma(CRUSHER_CRESTTOSS_COST)


	M.throw_at(T, toss_distance, 1, src)

	var/mob/living/carbon/Xenomorph/X = M
	//Handle the damage
	if(!istype(X) || hivenumber != X.hivenumber) //Friendly xenos don't take damage.
		var/damage = toss_distance * 5
		if(frenzy_aura)
			damage *= (1 + round(frenzy_aura * 0.1,0.01)) //+10% damage per level of frenzy
		var/armor_block = M.run_armor_check("chest", "melee")
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.take_overall_damage(rand(damage * 0.75,damage * 1.25), null, 0, 0, 0, armor_block) //Armour functions against this.
		else
			M.take_overall_damage(rand(damage * 0.75,damage * 1.25), 0, null, armor_block) //Armour functions against this.
		M.apply_damage(damage, HALLOSS) //...But decent armour ignoring Halloss
		shake_camera(M, 2, 2)
		playsound(M,pick('sound/weapons/alien_claw_block.ogg','sound/weapons/alien_bite2.ogg'), 50, 1)
		M.KnockDown(1, 1)

	addtimer(CALLBACK(src, .cresttoss_cooldown), CRUSHER_CRESTTOSS_COOLDOWN)
	addtimer(CALLBACK(src, .reset_intent_icon_state), 3)

/mob/living/carbon/Xenomorph/proc/reset_intent_icon_state()
	if(m_intent == MOVE_INTENT_RUN)
		icon_state = "Crusher Running"
	else
		icon_state = "Crusher Walking"

/mob/living/carbon/Xenomorph/proc/cresttoss_cooldown()
	if(!cresttoss_used)//sanity check/safeguard
		return
	cresttoss_used = FALSE
	to_chat(src, "<span class='xenowarning'><b>You can now crest toss again.</b></span>")
	playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
	update_action_buttons()
