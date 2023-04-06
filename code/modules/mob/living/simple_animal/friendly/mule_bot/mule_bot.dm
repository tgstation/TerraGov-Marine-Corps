
/obj/effect/mule_link/Initialize()
	. = ..()
	var/mob/living/simple_animal/mule_bot/M = new(loc)
	var/obj/item/remote/R = new(loc)
	M.try_link(R)
	R.bot = M
	qdel(src)


/mob/living/simple_animal/mule_bot
	name = "Felidae Beetle MK 1"
	desc = "A highly spohisticated load carrying robotic companion for the advanced marine. Manly as hell!"
	icon = 'icons/mob/kerfus.dmi'
	icon_state = "kerfus_blank"
	icon_living = "kerfus_blank"
	icon_dead = "kerfus"
	gender = FEMALE
	speak = list("Meow!", "Purr!", "Remember to stock up on medicine!", "Ill carry for the team!", "I sure do hope all these munations are safe...",
	"Did we really need to bring THAT many plasma cutters?", "Oh I may have the thing for that!","I don't think a xenomorphs head would fit...","Sometimes I wonder if moving bullets is the best way to make a living..","Please stop calling me a tin can...","Time to restock!")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows.", "mews.")
	emote_see = list("shakes its head.", "shivers.")
	speak_chance = 5
	turns_per_move = 5
	see_in_dark = 6
	flags_pass = PASSTABLE | PASSMOB | PASSXENO //to avoid it body blocking marines and xenos
	a_intent = INTENT_HELP
	mob_size = MOB_SIZE_SMALL
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	a_intent = INTENT_HELP
	light_system = MOVABLE_LIGHT
	flags_atom = BUMP_ATTACKABLE //bump attack may not work due to pass flags
	light_color =  "#3262db"
	light_range = 2
	light_power = 1
	light_on = FALSE
	//TODO to make this  hud actuely work
	hud_possible = list(MACHINE_HEALTH_HUD)
	maxHealth  = 200
	var/mutable_appearance/face_overlay
	var/obj/item/mule_module/installed_module
	var/obj/item/clothing/head/hat
	var/mutable_appearance/hat_overlay


/mob/living/simple_animal/mule_bot/Initialize()
	. = ..()
	face_overlay = emissive_appearance(icon, "kerfus_face")
	update_icon()

/mob/living/simple_animal/mule_bot/proc/try_link(obj/item/remote/R)
	if(R)
		AddComponent(/datum/component/ai_controller, /datum/ai_behavior/mule_bot, R)

/mob/living/simple_animal/mule_bot/update_overlays()
	. = ..()
	. += list(hat_overlay,face_overlay,installed_module?.mod_overlay)


/mob/living/simple_animal/mule_bot/attackby(obj/item/I, mob/living/user, def_zone)
	//give it a funny hat, could be turned into an actuel proc though
	if(istype(I,/obj/item/clothing/head))
		if(hat)
			hat.forceMove(src.loc)
		var/obj/item/clothing/head/new_hat = I
		I.forceMove(src)
		user?.temporarilyRemoveItemFromInventory(I)
		hat = new_hat
		hat_overlay = mutable_appearance(new_hat.get_worn_icon_file("Human",slot_head_str), new_hat.get_worn_icon_state(slot_head_str), HEAD_LAYER, FLOAT_PLANE)
		hat_overlay.pixel_y -= -5
		update_icon()
		return
	if(istype(I,/obj/item/mule_module))
		apply_module(I,user)
		return
	. = ..()

/mob/living/simple_animal/mule_bot/welder_act(mob/living/user, obj/item/I)
	var/repair_time = 1 SECONDS
	if(src == user)
		repair_time *= 3

	user.visible_message(span_notice("[user] starts to fix some of the dents on [src]."),\
		span_notice("You start fixing some of the dents on [src]"))

	add_overlay(GLOB.welding_sparks)
	while(do_after(user, repair_time, TRUE, src, BUSY_ICON_BUILD) && I.use_tool(volume = 50, amount = 2))
		user.visible_message(span_warning("\The [user] patches some dents on [src]."), \
			span_warning("You patch some dents on \the [src]."))
		if(src.heal_limb_damage(15,15, robo_repair = FALSE, updating_health = TRUE))
			UpdateDamageIcon()
		if(!I.tool_use_check(user, 2))
			break
		if(!src.bruteloss)
			balloon_alert(user, "Dents fully repaired.")
			break
	cut_overlay(GLOB.welding_sparks)
	return TRUE

/mob/living/simple_animal/mule_bot/crowbar_act(mob/living/user, obj/item/I)
	remove_module()
	return TRUE


/mob/living/simple_animal/mule_bot/proc/swap_module(obj/item/mule_module/mod, mob/user)
	remove_module(user, FALSE)
	apply_module(mod,user, FALSE)
	update_icon()

/mob/living/simple_animal/mule_bot/proc/apply_module(obj/item/mule_module/mod, mob/user, update_icon = TRUE)
	if(mod.apply(src))
		to_chat(user,span_notice("You succesfully installed [mod]"))
		user?.temporarilyRemoveItemFromInventory(mod)
	else
		to_chat(user,span_warning("You failed to installed [mod]"))
	if(update_icon)
		update_icon()

/mob/living/simple_animal/mule_bot/proc/remove_module(mob/user, update_icon = TRUE)
	if(!installed_module)
		return
	if(user)
		to_chat(user,span_notice("You succesfully remove [installed_module]"))
	installed_module.unapply(FALSE)
	if(update_icon)
		update_icon()


/obj/item/remote
	name = "remote"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "multitool2"
	var/mob/living/simple_animal/mule_bot/bot

/obj/item/remote/attack_self(mob/user)
	if(!bot)
		return
	if(SEND_SIGNAL(src, COMSIG_REMOTECONTROLL_STOP_FOLLOW, usr) & COMSIG_BOT_STOP)
		to_chat(user,span_notice("[bot] will now stop following"))
	else
		to_chat(user,span_notice("[bot] wil now follow you"))


/obj/item/remote/afterattack(turf/T, mob/living/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_SET_TARGET, user, T)
	to_chat(user, span_notice("[user] is now following [T]"))


/*
The bot has 2 modes
Follow and goto

In follow, it will follow the remote and who ever is holding it
in goto. it will go to a selected tile and stay there

*/
/datum/ai_behavior/mule_bot
	target_distance = 1
	base_action = ESCORTING_ATOM
	//The atom that will be used in only_set_escorted_atom proc, by default this atom is the remote
	var/datum/weakref/default_escorted_atom
	var/follow = FALSE

/datum/ai_behavior/mule_bot/New(loc, parent_to_assign, escorted_atom, can_heal = FALSE)
	. = ..()
	default_escorted_atom = WEAKREF(escorted_atom)
	RegisterSignal(escorted_atom, COMSIG_REMOTECONTROLL_STOP_FOLLOW, PROC_REF(stop_follow))
	RegisterSignal(escorted_atom, COMSIG_SET_TARGET, PROC_REF(go_to_obj_target))

/datum/ai_behavior/mule_bot/proc/stop_follow(atom/source, mob/user)
	SIGNAL_HANDLER
	if(follow)
		follow = FALSE
		atom_to_walk_to = null
		change_action(MOVING_TO_ATOM)
		mob_parent.say("Ill wait right here!")
		return COMSIG_BOT_STOP
	else
		follow = TRUE
		atom_to_walk_to = source
		change_action(ESCORTING_ATOM, source)
		mob_parent.say("Wait im up coming!")
		return COMSIG_BOT_FOLLOW

/// Sets escorted atom to our pre-defined default escorted atom, which by default is this spiderling's widow
/datum/ai_behavior/mule_bot/proc/only_set_escorted_atom(source, atom/A)
	SIGNAL_HANDLER
	escorted_atom = default_escorted_atom.resolve()

/// Check so that we dont keep attacking our target beyond it's death
/datum/ai_behavior/mule_bot/proc/go_to_obj_target(source, obj/remote, turf/target)
	SIGNAL_HANDLER
	if(QDELETED(target))
		return
	follow = FALSE
	atom_to_walk_to = target
	change_action(MOVING_TO_ATOM, target)
	mob_parent.say("Ill head on over!")
