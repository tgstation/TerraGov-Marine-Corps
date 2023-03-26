#define LEFT_HIT "Left Hit"
#define RIGHT_HIT "Right Hit"
#define COMBO_STEPS "steps"
#define COMBO_PROC "proc"
#define ATTACK_BASH "Bash"
#define ATTACK_SWEEP "Sweep"
#define ATTACK_DRAIN "Drain"
#define ATTACK_FLIP "Flip"
#define ATTACK_THROW "Throw Away"

/obj/item/weapon/twohanded/martialstaff
	name = "Martial Arts Staff"
	desc = "A martial arts staff, made out of the most pristine wood imaginable."
	icon_state = "martialstaff"
	item_state = "martialstaff"
	force = 10
	w_class = WEIGHT_CLASS_BULKY
	flags_equip_slot = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	flags_item = TWOHANDED
	force_wielded = 25
	attack_verb = list("attacked", "bashed", "smashed", "smacked", "bonked")
	attack_speed = 6
	attack_speed_alternate = 14

	hitsound = 'sound/weapons/wood_hit2.ogg'

	///How far can we throw things with toss/flip
	var/toss_distance

	///How much time has passed since the last time the user hit a mob
	var/last_hit_time
	///Tracks what hits the user has used
	var/list/input_list = list()
	///Used to update description when combos are added to combo_list
	var/list/combo_strings = list()
	///List of all combos that are possible to perform
	var/static/list/combo_list = list(
		ATTACK_BASH = list(COMBO_STEPS = list(LEFT_HIT, LEFT_HIT, LEFT_HIT), COMBO_PROC = PROC_REF(jab)),
		ATTACK_DRAIN = list(COMBO_STEPS = list(RIGHT_HIT, LEFT_HIT, LEFT_HIT), COMBO_PROC = PROC_REF(drain)),
		ATTACK_SWEEP = list(COMBO_STEPS = list(RIGHT_HIT, LEFT_HIT, RIGHT_HIT), COMBO_PROC = PROC_REF(sweep)),
		ATTACK_FLIP = list(COMBO_STEPS = list(RIGHT_HIT, RIGHT_HIT, LEFT_HIT), COMBO_PROC = PROC_REF(flip)),
		ATTACK_THROW = list(COMBO_STEPS = list(RIGHT_HIT, RIGHT_HIT, RIGHT_HIT), COMBO_PROC = PROC_REF(throw_away)),
	)

/obj/item/weapon/twohanded/martialstaff/Initialize()
	. = ..()
	for(var/combo in combo_list)
		var/list/combo_specifics = combo_list[combo]
		var/step_string = english_list(combo_specifics[COMBO_STEPS])
		combo_strings += span_notice("<b>[combo]</b> - [step_string]")

/obj/item/weapon/twohanded/martialstaff/examine(mob/user)
	. = ..()
	. += combo_strings

/obj/item/weapon/twohanded/martialstaff/attack(mob/living/carbon/xenomorph/target, mob/user, has_proximity, click_parameters)
	if(target.stat == DEAD || target == user)
		return ..()

	input_list += LEFT_HIT

	if(check_input(target, user))
		reset_inputs(null, TRUE)
		return TRUE
	else
		last_hit_time = addtimer(CALLBACK(src, PROC_REF(reset_inputs), user, FALSE), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		return ..()

/obj/item/weapon/twohanded/martialstaff/attack_alternate(mob/living/carbon/xenomorph/target, mob/user, has_proximity, click_parameters)
	if(target.stat == DEAD || target == user)
		return ..()

	input_list += RIGHT_HIT

	if(check_input(target, user))
		reset_inputs(null, TRUE)
		return TRUE
	else
		last_hit_time = addtimer(CALLBACK(src, PROC_REF(reset_inputs), user, FALSE), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
		return ..()

/obj/item/weapon/twohanded/martialstaff/proc/check_input(mob/living/target, mob/user)
	for(var/combo in combo_list)
		var/list/combo_specifics = combo_list[combo]
		if(compare_list(input_list,combo_specifics[COMBO_STEPS]))
			INVOKE_ASYNC(src, combo_specifics[COMBO_PROC], target, user)
			return TRUE
	if(length(input_list) >= 3)
		reset_inputs(user, TRUE)
	return FALSE

/obj/item/weapon/twohanded/martialstaff/proc/reset_inputs(mob/user, deltimer)
	input_list.Cut()
	if(user)
		balloon_alert(user, "you return to neutral stance")
	if(deltimer && last_hit_time)
		deltimer(last_hit_time)

/obj/item/weapon/twohanded/martialstaff/unique_action(mob/user, special_treatment)
	. = ..()
	reset_inputs(user, TRUE)


/obj/item/weapon/twohanded/martialstaff/proc/jab(mob/living/target, mob/user)
	balloon_alert(user, "Jab Attack")
	target.apply_damage(damage = 25)
	user.do_attack_animation(target, ATTACK_EFFECT_PUNCH)
	playsound(src, "sound/weapons/punch3.ogg", 25)

/obj/item/weapon/twohanded/martialstaff/proc/sweep(mob/living/target, mob/user)


	balloon_alert(user, "Sweep")

	var/sweep_range = 2
	var/list/effect_radius = orange(sweep_range, user)

	///Makes the user spin and plays the spin sound.
	user.add_filter("defender_tail_sweep", 2, gauss_blur_filter(1)) //Add cool SFX
	user.spin(8, 1)
	playsound(user, pick('sound/effects/alien_tail_swipe1.ogg','sound/effects/alien_tail_swipe2.ogg','sound/effects/alien_tail_swipe3.ogg'), 25, 1) //Sound effects

	for(var/mob/living/carbon/xenomorph/xeno in effect_radius)
		step_away(xeno, src, sweep_range, 4)
		xeno.add_filter("defender_tail_sweep", 2, gauss_blur_filter(1)) //Add cool SFX; motion blur
		addtimer(CALLBACK(xeno, TYPE_PROC_REF(/atom, remove_filter), "defender_tail_sweep"), 0.5 SECONDS) //Remove cool SFX

		var/damage = 50
		xeno.apply_damage(damage, BRUTE, MELEE)

		xeno.Paralyze(5) //trip and go
		shake_camera(xeno, 2, 1)
		to_chat(xeno, span_warning("We are struck by \the [user]'s sweep!"))
		playsound(xeno,'sound/weapons/alien_claw_block.ogg', 50, 1)

	addtimer(CALLBACK(user, TYPE_PROC_REF(/atom, remove_filter), "defender_tail_sweep"), 1 SECONDS) //Remove cool SFX


/obj/item/weapon/twohanded/martialstaff/proc/drain(mob/living/target, mob/user)
	balloon_alert(user, "Drain")



/obj/item/weapon/twohanded/martialstaff/proc/flip(mob/living/target, mob/user)
	balloon_alert(user, "Toss")
	user.do_attack_animation(target, ATTACK_EFFECT_GRAB)

	user.face_atom(target) //Face towards the target so we don't look silly
	var/facing = get_dir(user, target)
	var/turf/T = user.loc
	var/turf/temp = user.loc


	facing = get_dir(target, user)
	var/turf/throw_origin = get_step(T, facing)
	if(isclosedturf(throw_origin)) //Make sure the victim can actually go to the target turf
		to_chat(user, span_xenowarning("We try to fling [target] behind us, but there's no room!"))
		return
	for(var/obj/O in throw_origin)
		if(!O.CanPass(target, get_turf(user)) && !istype(O, /obj/structure/barricade)) //Ignore barricades because they will once thrown anyway
			to_chat(user, span_xenowarning("We try to fling [target] behind us, but there's no room!"))
			return

	target.forceMove(throw_origin) //Move the victim behind us before flinging
	toss_distance = 1
	for(var/x = 0, x < toss_distance, x++)
		temp = get_step(T, facing)
		if (!temp)
			break
		T = temp //Throw target

	target.throw_at(T, toss_distance, 3, user, TRUE)

	playsound(loc, 'sound/weapons/energy_blast.ogg', 50, TRUE)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, TRUE)



/obj/item/weapon/twohanded/martialstaff/proc/throw_away(mob/living/target, mob/user)
	balloon_alert(user, "Throw")
	user.do_attack_animation(target, ATTACK_EFFECT_GRAB)

	user.face_atom(target) //Face towards the target so we don't look silly
	var/facing = get_dir(user, target)
	var/turf/T = user.loc
	var/turf/temp = user.loc

	toss_distance = 4
	for(var/x in 1 to toss_distance)
		temp = get_step(T, facing)
		if (!temp)
			break
		T = temp

	target.throw_at(T, toss_distance, 3, user, TRUE)

	playsound(loc, 'sound/weapons/energy_blast.ogg', 50, TRUE)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, TRUE)

















#undef LEFT_HIT
#undef RIGHT_HIT
#undef COMBO_STEPS
#undef COMBO_PROC
#undef ATTACK_BASH
#undef ATTACK_SWEEP

#undef ATTACK_FLIP
#undef ATTACK_THROW
