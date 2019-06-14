// ***************************************
// *********** Stomp
// ***************************************
/datum/action/xeno_action/activable/stomp
	name = "Stomp"
	action_icon_state = "stomp"
	mechanics_text = "Knocks all adjacent targets away and down."
	ability_name = "stomp"
	plasma_cost = 80
	cooldown_timer = 20 SECONDS
	keybind_flags = XACT_KEYBIND_USE_ABILITY
	keybind_signal = COMSIG_XENOABILITY_STOMP

/datum/action/xeno_action/activable/stomp/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/crusher/X = owner
	succeed_activate()
	add_cooldown()

	round_statistics.crusher_stomps++

	playsound(X.loc, 'sound/effects/bang.ogg', 25, 0)
	X.visible_message("<span class='xenodanger'>[X] smashes into the ground!</span>", \
	"<span class='xenodanger'>You smash into the ground!</span>")
	X.create_stomp() //Adds the visual effect. Wom wom wom

	for(var/mob/living/M in range(2,X.loc))
		if(isxeno(M) || M.stat == DEAD || isnestedhost(M))
			continue
		var/distance = get_dist(M, X)
		var/damage = (rand(CRUSHER_STOMP_LOWER_DMG, CRUSHER_STOMP_UPPER_DMG) * CRUSHER_STOMP_UPGRADE_BONUS(X)) / max(1,distance + 1)
		damage += FRENZY_DAMAGE_BONUS(X)
		if(distance == 0) //If we're on top of our victim, give him the full impact
			round_statistics.crusher_stomp_victims++
			var/armor_block = M.run_armor_check("chest", "melee") * 0.5 //Only 50% armor applies vs stomp brute damage
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.take_overall_damage(damage, null, 0, 0, 0, armor_block) //Armour functions against this.
			else
				M.take_overall_damage(damage, 0, null, armor_block) //Armour functions against this.
			to_chat(M, "<span class='highdanger'>You are stomped on by [X]!</span>")
			shake_camera(M, 3, 3)
		else
			step_away(M, X, 1) //Knock away
			shake_camera(M, 2, 2)
			to_chat(M, "<span class='highdanger'>You reel from the shockwave of [X]'s stomp!</span>")
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
	keybind_signal = COMSIG_XENOABILITY_TOGGLE_CHARGE

/datum/action/xeno_action/ready_charge/action_activate()
	var/mob/living/carbon/xenomorph/X = owner
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
	plasma_cost = 40
	cooldown_timer = 6 SECONDS
	keybind_signal = COMSIG_XENOABILITY_CRESTTOSS

/datum/action/xeno_action/activable/cresttoss/on_cooldown_finish()
	to_chat(src, "<span class='xenowarning'><b>You can now crest toss again.</b></span>")
	playsound(src, 'sound/effects/xeno_newlarva.ogg', 50, 0, 1)
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
	if(L.mob_size >= MOB_SIZE_BIG)
		if(!silent)
			to_chat(owner, "<span class='xenowarning'>[L] is too large to fling!</span>")
		return FALSE

/datum/action/xeno_action/activable/cresttoss/use_ability(atom/A)
	var/mob/living/carbon/xenomorph/X = owner
	var/mob/living/L = A
	X.face_atom(L) //Face towards the target so we don't look silly

	var/facing = get_dir(X, L)
	var/toss_distance = rand(3,5)
	var/turf/T = X.loc
	var/turf/temp = X.loc
	if(X.a_intent == INTENT_HARM) //If we use the ability on hurt intent, we throw them in front; otherwise we throw them behind.
		for (var/x in 1 to toss_distance)
			temp = get_step(T, facing)
			if (!temp)
				break
			T = temp
	else
		facing = get_dir(L, X)
		if(!X.check_blocked_turf(get_step(T, facing) ) ) //Make sure we can actually go to the target turf
			L.loc = get_step(T, facing) //Move the target behind us before flinging
			for (var/x = 0, x < toss_distance, x++)
				temp = get_step(T, facing)
				if (!temp)
					break
				T = temp
		else
			to_chat(X, "<span class='xenowarning'>You try to fling [L] behind you, but there's no room!</span>")
			return fail_activate()

	//The target location deviates up to 1 tile in any direction
	var/scatter_x = rand(-1,1)
	var/scatter_y = rand(-1,1)
	var/turf/new_target = locate(T.x + round(scatter_x),T.y + round(scatter_y),T.z) //Locate an adjacent turf.
	if(new_target)
		T = new_target//Looks like we found a turf.

	X.icon_state = "Crusher Charging"  //Momentarily lower the crest for visual effect

	X.visible_message("<span class='xenowarning'>\The [X] flings [L] away with its crest!</span>", \
	"<span class='xenowarning'>You fling [L] away with your crest!</span>")

	succeed_activate()

	L.throw_at(T, toss_distance, 1, X)

	//Handle the damage
	if(!X.issamexenohive(L)) //Friendly xenos don't take damage.
		var/damage = toss_distance * 5
		damage += FRENZY_DAMAGE_BONUS(X)
		var/armor_block = L.run_armor_check("chest", "melee")
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			H.take_overall_damage(rand(damage * 0.75,damage * 1.25), null, 0, 0, 0, armor_block) //Armour functions against this.
		else
			L.take_overall_damage(rand(damage * 0.75,damage * 1.25), 0, null, armor_block) //Armour functions against this.
		L.apply_damage(damage, HALLOSS) //...But decent armour ignoring Halloss
		shake_camera(L, 2, 2)
		playsound(L,pick('sound/weapons/alien_claw_block.ogg','sound/weapons/alien_bite2.ogg'), 50, 1)
		L.KnockDown(1, 1)

	add_cooldown()
	addtimer(CALLBACK(X, /mob/.proc/update_icons), 3)
