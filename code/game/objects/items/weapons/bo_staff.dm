#define LEFT_HIT "Left Hit"
#define RIGHT_HIT "Right Hit"
#define UNIQUE_HIT "Unique Action"

#define COMBO_STEPS "steps"
#define COMBO_PROC "proc"

#define ATTACK_BASH "Bash"
#define ATTACK_SWEEP "Sweep"
#define ATTACK_DRAIN "Drain"
#define ATTACK_FLIP "Flip"
#define ATTACK_THROW "Throw Away"

#define STANCE_EMPOWER "Empower"
#define STANCE_PARRY "Parry"
#define STANCE_HEAL "Heal"
#define STANCE_HEAL_ALT "Heal Alternate"

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

	/*greyscale_config = /datum/greyscale_config/martialstaff
	greyscale_colors = COLOR_LASER_BLUE*/

	hitsound = 'sound/weapons/wood_hit2.ogg'

	///Storage for the flame overlay that gets put on the in-hand sprite
	var/mutable_appearance/flame_overlay











	var/list/mutable_appearance/in_hand_fire_overlay = list()
	var/list/mutable_appearance/fire_overlay = list()
	///How far can we throw things with toss/flip
	var/toss_distance

	///How much time has passed since the last time the user hit a mob
	var/last_hit_time

	///Color of the flame that gets overlayed on top of the in-hand sprite
	var/flame_color = LIGHT_COLOR_WHITE
	///Color of the flame that gets overlayed on top of the in-hand sprite after a light attack
	var/flame_color_light = COLOR_CYAN
	///Color of the flame that gets overlayed on top of the in-hand sprite after a heavy attack
	var/flame_color_heavy = COLOR_MAROON

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

		//Stances the user can enter
		STANCE_EMPOWER = list(COMBO_STEPS = list(LEFT_HIT, LEFT_HIT, UNIQUE_HIT), COMBO_PROC = PROC_REF(empower)),
		STANCE_PARRY = list(COMBO_STEPS = list(RIGHT_HIT, RIGHT_HIT, UNIQUE_HIT), COMBO_PROC = PROC_REF(parry)),
		STANCE_HEAL = list(COMBO_STEPS = list(LEFT_HIT, RIGHT_HIT, UNIQUE_HIT), COMBO_PROC = PROC_REF(heal)),
		STANCE_HEAL_ALT = list(COMBO_STEPS = list(RIGHT_HIT, LEFT_HIT, UNIQUE_HIT), COMBO_PROC = PROC_REF(heal)), //Heal has 2 possible combos
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

/obj/item/weapon/twohanded/martialstaff/attack(mob/living/carbon/xenomorph/target, mob/user)
	. = ..()
	if(target.stat == DEAD || target == user)
		return

	if(check_input(target, user, LEFT_HIT))
		reset_inputs(null, TRUE)
	else
		last_hit_time = addtimer(CALLBACK(src, PROC_REF(reset_inputs), user, FALSE), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/obj/item/weapon/twohanded/martialstaff/attack_alternate(mob/living/carbon/xenomorph/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if(target.stat == DEAD || target == user)
		return

	if(check_input(target, user, RIGHT_HIT))
		reset_inputs(null, TRUE)
	else
		last_hit_time = addtimer(CALLBACK(src, PROC_REF(reset_inputs), user, FALSE), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)

/**
 * Checks the inputs to see if it matches a combo
 * Arguments:
 * * hit_side - Wether it's left click, right click or unique action
 * Returns a specific combo
 */
/obj/item/weapon/twohanded/martialstaff/proc/check_input(mob/living/target, mob/user, hit_side)
	input_list += hit_side

	for(var/combo in combo_list)
		var/list/combo_specifics = combo_list[combo]
		if(compare_list(input_list, combo_specifics[COMBO_STEPS]))
			INVOKE_ASYNC(src, combo_specifics[COMBO_PROC], target, user)
			return TRUE

	//Resets the combo if you go over the maximum combo possible.
	if(length(input_list) >= 3)
		reset_inputs(user, TRUE)
	else
		add_fire_overlay(hit_side)
	return FALSE

/**
 * Adds the fire overlay to the staff
 * Arguments:
 * * is_right_click - Whether this was called by a right-click or not, to give a different flame color.
 * Returns nothing
 */
/obj/item/weapon/twohanded/martialstaff/proc/add_fire_overlay(hit_side)
	var/existing_overlay = !!length(fire_overlay)
	var/mutable_appearance/new_overlay = mutable_appearance('icons/effects/effects.dmi', "flame")
	new_overlay.color = (hit_side == RIGHT_HIT) ? flame_color_heavy : flame_color_light
	if(existing_overlay)
		new_overlay.icon_state = "flame1"
		new_overlay.pixel_y = 12
	add_overlay(list(new_overlay))
	fire_overlay.Add(new_overlay)
	generate_flame_overlay(new_overlay, hit_side)




/////// add_flame ///////////////////

/*/obj/item/weapon/twohanded/martialstaff/add_flame(flame_color)
	if(flame_color)
		flame_color = flame_color
	return TRUE

	if(!flame_overlay)//apply the blood-splatter overlay if it isn't already in there
		generate_flame_overlay()

	else if(flame_overlay && flame_color && flame_overlay.color != flame_color)
		overlays -= flame_overlay
		flame_overlay.color = flame_color
		overlays += flame_overlay
	return TRUE //we applied blood to the item
	*/


/obj/item/weapon/twohanded/martialstaff/proc/generate_flame_overlay(flame_color, hit_side)
	if(!flame_overlay)
		flame_overlay = new /icon('icons/effects/effects.dmi', "flame")
		flame_overlay.color = (hit_side == RIGHT_HIT) ? flame_color_heavy : flame_color_light
		overlays += flame_overlay









/**
 * Resets the inputs and overlays from the staff
 * Arguments:
 * * user - The person holding the staff
 * * deltimer - Whether the timer should be deleted or not.
 * Returns nothing.
 */
/obj/item/weapon/twohanded/martialstaff/proc/reset_inputs(mob/user, deltimer)
	cut_overlay(fire_overlay)
	fire_overlay.Cut()
	input_list.Cut()
	if(user)
		balloon_alert(user, "you return to neutral stance")
	if(deltimer && last_hit_time)
		deltimer(last_hit_time)

/obj/item/weapon/twohanded/martialstaff/unique_action(mob/user, special_treatment)
	. = ..()

	if(check_input(user, user, UNIQUE_HIT)) //Target is user since the stance is a self-buff
		reset_inputs(null, TRUE)
		return
	reset_inputs(user, TRUE) //Resets your combo if you only have 1 flame


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


/obj/item/weapon/twohanded/martialstaff/proc/empower(mob/living/target, mob/user)
	balloon_alert(user, "Empower")
	///Speed increase of swings from being empowered
	var/strike_speed = 3
	attack_speed = initial(attack_speed) - strike_speed
	attack_speed_alternate = initial(attack_speed_alternate) - strike_speed


/obj/item/weapon/twohanded/martialstaff/proc/parry(mob/living/target, mob/user)
	balloon_alert(user, "Parry Stance")


/obj/item/weapon/twohanded/martialstaff/proc/heal(mob/living/target, mob/user)
	balloon_alert(user, "Heal")














#undef LEFT_HIT
#undef RIGHT_HIT
#undef UNIQUE_HIT

#undef COMBO_STEPS
#undef COMBO_PROC

#undef ATTACK_BASH
#undef ATTACK_SWEEP
#undef ATTACK_DRAIN
#undef ATTACK_FLIP
#undef ATTACK_THROW

#undef STANCE_EMPOWER
#undef STANCE_PARRY
#undef STANCE_HEAL
#undef STANCE_HEAL_ALT

