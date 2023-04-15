
/obj/effect/mule_link/Initialize()
	. = ..()
	var/mob/living/simple_animal/mule_bot/M = new(loc)
	var/obj/item/remote/R = new(loc)
	M.try_link(R)
	qdel(src)


//we use simple animal here primairly to attach AI behavior too it. Aswel as having all the movement stuff baked in.
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
	//the remote currenty linked to this bot. used for controlling
	var/obj/item/remote/linked_remote
	var/mutable_appearance/face_overlay
	//currently installed modules, see mule_but_modules.dm
	var/obj/item/mule_module/installed_module
	//You can put a hat on the bots head and he we will wear it
	var/obj/item/clothing/head/hat
	var/mutable_appearance/hat_overlay


/mob/living/simple_animal/mule_bot/Initialize()
	. = ..()
	face_overlay = emissive_appearance(icon, "kerfus_face")
	update_icon()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior/mule_bot)

/mob/living/simple_animal/mule_bot/proc/try_link(obj/item/remote/new_remote)
	if(linked_remote)
		SEND_SIGNAL(src, COMSIG_REMOTE_UNLINK)
		linked_remote = null
	if(SEND_SIGNAL(src, COMSIG_REMOTE_LINK, new_remote))
		linked_remote = new_remote
		new_remote.bot = src


/mob/living/simple_animal/mule_bot/update_overlays()
	. = ..()
	. += list(hat_overlay,face_overlay,installed_module?.mod_overlay)


/mob/living/simple_animal/mule_bot/attackby(obj/item/I, mob/living/user, def_zone)
	if(istype(I,/obj/item/remote))
		try_link(I)
	//give it a funny hat to wear, could be turned into an actuel proc though
	if(istype(I,/obj/item/clothing/head))
		if(hat)
			hat.forceMove(loc)
		var/obj/item/clothing/head/new_hat = I
		I.forceMove(src)
		user?.temporarilyRemoveItemFromInventory(I)
		hat = new_hat
		hat_overlay = mutable_appearance(new_hat.get_worn_icon_file("Human",slot_head_str), new_hat.get_worn_icon_state(slot_head_str), HEAD_LAYER, FLOAT_PLANE)
		hat_overlay.pixel_y -= -5
		update_icon()
		return
	if(istype(I,/obj/item/mule_module))
		swap_module(I,user)
		return
	return ..()

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
		if(heal_limb_damage(15,15, robo_repair = FALSE, updating_health = TRUE))
			UpdateDamageIcon()
		if(!I.tool_use_check(user, 2))
			break
		if(!bruteloss)
			balloon_alert(user, "Dents fully repaired.")
			break
	cut_overlay(GLOB.welding_sparks)
	return TRUE

/mob/living/simple_animal/mule_bot/crowbar_act(mob/living/user, obj/item/I)
	remove_module()
	return TRUE

//Swap 1 module for another, use this if you want to apply module on existing bot
/mob/living/simple_animal/mule_bot/proc/swap_module(obj/item/mule_module/mod, mob/user)
	remove_module(user, FALSE)
	apply_module(mod,user, FALSE)
	update_icon()


//apply the module from the bot
/mob/living/simple_animal/mule_bot/proc/apply_module(obj/item/mule_module/mod, mob/user, update_icon = TRUE)
	if(mod.apply(src))
		to_chat(user,span_notice("You succesfully installed [mod]"))
		user?.temporarilyRemoveItemFromInventory(mod)
	else
		to_chat(user,span_warning("You failed to installed [mod]"))
	if(update_icon)
		update_icon()


//removes the module from the bot
/mob/living/simple_animal/mule_bot/proc/remove_module(mob/user, update_icon = TRUE)
	if(!installed_module)
		return
	if(user)
		to_chat(user,span_notice("You succesfully remove [installed_module]"))
	installed_module.unapply(FALSE)
	if(update_icon)
		update_icon()


/obj/item/remote
	name = "Felidae Beetle remote"
	desc = "Controlls a mighty mule of a robot."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "multitool2"
	var/mob/living/simple_animal/mule_bot/bot

/obj/item/remote/attack_self(mob/user)
	if(!bot)
		return
	if(SEND_SIGNAL(src, COMSIG_REMOTE_CONTROLL_STOP_FOLLOW, usr))
		balloon_alert(user,span_notice("[bot] wil now follow you"))


/obj/item/remote/afterattack(turf/T, mob/living/user)
	. = ..()
	SEND_SIGNAL(src, COMSIG_SET_TARGET, user, T)
	balloon_alert(user, span_notice("[user] is now following [T]"))


/*
The bot has 2 modes
Follow and goto

In follow, it will follow the remote and who ever is holding it
in goto. it will go to a selected tile and stay there

im using ai behavior currently but a companion component could also fit

*/
/datum/ai_behavior/mule_bot
	target_distance = 1
	base_action = ESCORTING_ATOM
	//The atom that will be used in only_set_escorted_atom proc, by default this atom is the remote
	var/follow = FALSE
	var/datum/weakref/linked_remote

/datum/ai_behavior/mule_bot/New(loc, parent_to_assign, escorted_atom, can_heal = FALSE)
	. = ..()
	RegisterSignal(parent_to_assign, COMSIG_REMOTE_UNLINK,PROC_REF(unlink_remote))
	RegisterSignal(parent_to_assign, COMSIG_REMOTE_LINK,PROC_REF(link_remote))

/datum/ai_behavior/mule_bot/Destroy(force, ...)
	unlink_remote()
	UnregisterSignal(mob_parent, COMSIG_REMOTE_UNLINK,PROC_REF(unlink_remote))
	UnregisterSignal(mob_parent, COMSIG_REMOTE_LINK,PROC_REF(link_remote))
	return ..()

//unlink the currenly attached remote
/datum/ai_behavior/mule_bot/proc/unlink_remote()
	var/obj/item/remote/remote = linked_remote.resolve()
	if(remote)
		UnregisterSignal(remote, COMSIG_REMOTE_CONTROLL_STOP_FOLLOW)
		UnregisterSignal(remote, COMSIG_SET_TARGET)
		UnregisterSignal(remote, COMSIG_PARENT_QDELETING)


//links the remote, if this runtimes somehow and cutts off it will return null and not link
/datum/ai_behavior/mule_bot/proc/link_remote(mob/mule, obj/item/remote/new_remote)
	linked_remote = WEAKREF(new_remote)
	RegisterSignal(new_remote, COMSIG_REMOTE_CONTROLL_STOP_FOLLOW, PROC_REF(follow))
	RegisterSignal(new_remote, COMSIG_SET_TARGET, PROC_REF(go_to_obj_target))

	//if remote kicks the bucket some how before the mule bot does
	RegisterSignal(new_remote, COMSIG_PARENT_QDELETING, PROC_REF(unlink_remote))

	return TRUE

/datum/ai_behavior/mule_bot/proc/follow(atom/source, mob/user)
	SIGNAL_HANDLER
	follow = TRUE
	atom_to_walk_to = source
	change_action(ESCORTING_ATOM, source)
	mob_parent.say("Wait up im coming!")
	return TRUE

/// Check so that we dont keep attacking our target beyond it's death
/datum/ai_behavior/mule_bot/proc/go_to_obj_target(source, obj/remote, turf/target)
	SIGNAL_HANDLER
	if(QDELETED(target))
		return
	follow = FALSE
	atom_to_walk_to = target
	change_action(MOVING_TO_ATOM, target)
	mob_parent.say("Ill head on over!")
