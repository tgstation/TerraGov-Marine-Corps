
/obj/effect/mule_link/Initialize()
	. = ..()
	var/mob/living/simple_animal/mule_bot/M = new(loc)
	var/obj/item/remote/R = new(loc)
	M.try_link(R)
	R.bot = M
	qdel(src)

/obj/item/storage/backpack/mule_pack
	name = "internal storage"
	flags_equip_slot = ITEM_SLOT_BACK
	max_w_class = 6
	max_storage_space = 48

/mob/living/simple_animal/mule_bot
	name = "Felidae Beetle MK 1"
	desc = "A highly spohisticated load carrying robotic companion for the advanced marine. Manly as hell!"
	icon = 'icons/mob/mule_bot.dmi'
	icon_state = "mule_bot"
	icon_living = "mule_bot"
	icon_dead = "mule_bot"
	gender = FEMALE
	speak = list("Meow!", "Purr!", "Remember to stock up on medicine!", "Ill carry for the team!", "I sure do hope all these munations are safe...","Did we really need to bring THAT many plasma cutters?", "Oh I may have the thing for that!","I don't think a xenomorphs head would fit...")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows.", "mews.")
	emote_see = list("shakes its head.", "shivers.")
	speak_chance = 9
	turns_per_move = 5
	see_in_dark = 6
	flags_pass = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	var/obj/item/storage/backpack/mule_pack/storage_pack = /obj/item/storage/backpack/mule_pack

/mob/living/simple_animal/mule_bot/Initialize()
	. = ..()
	storage_pack = new storage_pack(src)

/mob/living/simple_animal/mule_bot/proc/try_link(obj/item/remote/R)
	if(R)
		AddComponent(/datum/component/ai_controller, /datum/ai_behavior/mule_bot, R)

/mob/living/simple_animal/mule_bot/attack_hand(mob/living/user)
	storage_pack.open(user)

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

/datum/ai_behavior/mule_bot
	target_distance = 1
	base_action = ESCORTING_ATOM
	//The atom that will be used in only_set_escorted_atom proc, by default this atom is the spiderling's widow
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
		change_action(IDLE)
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

/// Check if escorted_atom moves away from the spiderling while it's attacking something, this is to always keep them close to escorted_atom
// /datum/ai_behavior/mule_bot/look_for_new_state()
// 	if(current_action == MOVING_TO_ATOM)
// 		if(escorted_atom && !(mob_parent.Adjacent(escorted_atom)))
// 			change_action(ESCORTING_ATOM, escorted_atom)

/// Check so that we dont keep attacking our target beyond it's death
/datum/ai_behavior/mule_bot/proc/go_to_obj_target(source, obj/remote, turf/target)
	SIGNAL_HANDLER
	if(QDELETED(target))
		return
	follow = FALSE
	atom_to_walk_to = target
	change_action(MOVING_TO_ATOM, target)
	mob_parent.say("Ill head on over!")
