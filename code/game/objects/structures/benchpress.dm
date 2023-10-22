/obj/structure/benchpress
	name = "weight training bench"
	desc = "Just looking at this thing makes you feel tired.<br>Left click to bench, right click to change weights."
	icon = 'icons/obj/structures/benchpress.dmi'
	icon_state = "benchpress_0"
	base_icon_state = "benchpress"
	density = FALSE
	anchored = TRUE
	pixel_x = -17
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	var/datum/looping_sound/benchpress_creak/creak_loop
	///amount of plates we are using, used to keep track for animations
	var/plates = 0

/obj/structure/benchpress/Initialize(mapload)
	. = ..()
	creak_loop = new
	update_icon()

/obj/structure/benchpress/wrench_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	if(anchored)
		balloon_alert(user, "unsecured")
		anchored = FALSE
	else
		balloon_alert(user, "secured")
		anchored = TRUE
	return TRUE

/obj/structure/benchpress/crowbar_act(mob/living/user, obj/item/tool)
	if(anchored)
		balloon_alert(user, "unsecure first!")
		return FALSE
	tool.play_tool_sound(src)
	balloon_alert(user, "deconstructing...")
	if(!do_after(user, 10 SECONDS, target = src))
		return FALSE
	new /obj/item/stack/sheet/metal(get_turf(src))
	new /obj/item/stack/rods(get_turf(src))
	new /obj/item/stack/rods(get_turf(src))
	qdel(src)
	return TRUE

/obj/structure/benchpress/update_icon_state()
	. = ..()
	icon_state = HAS_TRAIT(src, BENCH_BEING_USED) ? "[base_icon_state]_u" : "[base_icon_state]_[plates]"

/obj/structure/benchpress/update_overlays()
	. = ..()

	if(HAS_TRAIT(src, BENCH_BEING_USED))
		. += mutable_appearance(icon, "[base_icon_state]_[plates]_anim", plane = GAME_PLANE, layer = ABOVE_MOB_LAYER, alpha = src.alpha)

/obj/structure/benchpress/attack_hand_alternate(mob/living/user)
	. = ..()
	if(.)
		return
	if(HAS_TRAIT(src, BENCH_BEING_USED))
		return
	if(plates)
		var/oldplates = plates
		plates = 0
		update_icon()
		flick("unswap_[oldplates]", src)
		return
	var/list/radial_options = list(
		"1" = image(icon = 'icons/obj/structures/benchpress.dmi', icon_state = "benchpress_1"),
		"2" = image(icon = 'icons/obj/structures/benchpress.dmi', icon_state = "benchpress_2"),
		"3" = image(icon = 'icons/obj/structures/benchpress.dmi', icon_state = "benchpress_3"),
		"4" = image(icon = 'icons/obj/structures/benchpress.dmi', icon_state = "benchpress_4"),
		"5" = image(icon = 'icons/obj/structures/benchpress.dmi', icon_state = "benchpress_5"),
	)
	var/choice = show_radial_menu(user, src, radial_options, null, 64, null, TRUE, TRUE)
	if(!choice)
		return
	plates = text2num(choice)
	update_icon()
	flick("swap_[plates]", src)



/obj/structure/benchpress/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	do_workout_set(user)

/obj/structure/benchpress/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	. = ..()
	if(.)
		return
	do_workout_set(X)

///checks if possible and if yes performs a workout set for this mob
/obj/structure/benchpress/proc/do_workout_set(mob/living/user)
	if(HAS_TRAIT(src, BENCH_BEING_USED))
		balloon_alert(user, "wait your turn!")
		return
	ADD_TRAIT(src, BENCH_BEING_USED, WEIGHTBENCH_TRAIT) // yea this is meh but IN_USE and interact code are a mess rn and too buggy so less sidestep it
	update_icon()
	user.setDir(SOUTH)
	user.flags_atom |= DIRLOCK
	ADD_TRAIT(user, TRAIT_IMMOBILE, WEIGHTBENCH_TRAIT)
	user.forceMove(loc)
	var/bragmessage = pick("pushing it to the limit","going into overdrive","burning with determination","rising up to the challenge", "getting strong now","getting ripped")
	user.visible_message("<B>[user] is [bragmessage]!</B>")
	addtimer(CALLBACK(src, PROC_REF(finish_press), user), 50)
	creak_loop.start(src)

///cleans up releases exerciser
/obj/structure/benchpress/proc/finish_press(mob/living/user)
	creak_loop.stop(src)
	playsound(user, 'sound/machines/click.ogg', 60, TRUE)
	REMOVE_TRAIT(src, BENCH_BEING_USED, WEIGHTBENCH_TRAIT)
	user.flags_atom &= ~DIRLOCK
	REMOVE_TRAIT(user, TRAIT_IMMOBILE, WEIGHTBENCH_TRAIT)
	update_icon()
	if(user.faction)
		GLOB.round_statistics.workout_counts[user.faction] += 1
	if(plates >= 5 && prob(10) && ishuman(user)) // the flesh is weak
		var/mob/living/carbon/human/breaker = user
		var/datum/limb/broken = breaker.get_limb(pick("l_arm", "r_arm"))
		broken.fracture()
		return
	if(!HAS_TRAIT(user, TRAIT_WORKED_OUT))
		user.set_skills(user.skills.modifyRating(cqc=1))
		ADD_TRAIT(user, TRAIT_WORKED_OUT, WEIGHTBENCH_TRAIT)
		addtimer(CALLBACK(src, PROC_REF(undo_buff), WEAKREF(user)), 15 MINUTES)
	var/finishmessage = pick("You feel stronger!","You feel like you're the boss of this gym!","You feel robust!","The challenge is real!")
	var/mob/living/carbon/bencher = user
	if(bencher.nutrition >= NUTRITION_OVERFED)
		var/weight_to_lose = NUTRITION_OVERFED - bencher.nutrition
		bencher.adjust_nutrition(weight_to_lose)
		finishmessage = pick("You no longer feel overweight.","You clothes are no longer too tight.","YOU BECOME LESS FAT!")
	to_chat(user, finishmessage)
	if(user.client)
		var/datum/personal_statistics/personal_statistics = GLOB.personal_statistics_list[user.ckey]
		personal_statistics.weights_lifted++

///proc to undo the cqc buff granted by the bench
/obj/structure/benchpress/proc/undo_buff(datum/weakref/user_ref)
	var/mob/user = user_ref.resolve()
	if(!user)
		return
	REMOVE_TRAIT(user, TRAIT_WORKED_OUT, WEIGHTBENCH_TRAIT)
	user.set_skills(user.skills.modifyRating(cqc=-1))
	to_chat(user, span_boldnotice("You no longer feel as fit as you used to!"))

