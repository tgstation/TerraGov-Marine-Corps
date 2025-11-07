///Rallies nearby zombies
/proc/global_rally_zombies(atom/rally_point, global_rally = FALSE)
	SEND_GLOBAL_SIGNAL(COMSIG_GLOB_AI_ZOMBIE_RALLY, rally_point, global_rally)

/datum/action/rally_zombie
	name = "Rally Zombies"
	action_icon_state = "rally_minions"
	action_icon = 'icons/Xeno/actions/leader.dmi'

/datum/action/rally_zombie/action_activate()
	owner.balloon_alert(owner, "Zombies Rallied!")
	global_rally_zombies(owner)
	var/datum/action/set_agressivity/set_agressivity = owner.actions_by_path[/datum/action/set_agressivity]
	if(set_agressivity)
		SEND_SIGNAL(owner, COMSIG_ESCORTING_ATOM_BEHAVIOUR_CHANGED, set_agressivity.zombies_agressive) //New escorting ais should have the same behaviour as old one

/datum/action/set_agressivity
	name = "Set other zombie behavior"
	action_icon_state = "minion_agressive"
	action_icon = 'icons/Xeno/actions/leader.dmi'
	///If zombies should be agressive
	var/zombies_agressive = TRUE

/datum/action/set_agressivity/action_activate()
	zombies_agressive = !zombies_agressive
	SEND_SIGNAL(owner, COMSIG_ESCORTING_ATOM_BEHAVIOUR_CHANGED, zombies_agressive)
	update_button_icon()

/datum/action/set_agressivity/update_button_icon()
	action_icon_state = zombies_agressive ? "minion_agressive" : "minion_passive"
	return ..()

/obj/item/weapon/zombie_claw
	name = "claws"
	hitsound = 'sound/weapons/slice.ogg'
	icon_state = "zombie_claw_left"
	base_icon_state = "zombie_claw"
	force = 20
	sharp = IS_SHARP_ITEM_BIG
	edge = TRUE
	attack_verb = list("claws", "slashes", "tears", "rips", "dices", "cuts", "bites")
	item_flags = CAN_BUMP_ATTACK|DELONDROP
	attack_speed = 8 //Same as unarmed delay
	pry_capable = IS_PRY_CAPABLE_FORCE
	///How much zombium is transferred per hit. Set to zero to remove transmission
	var/zombium_per_hit = 5

/obj/item/weapon/zombie_claw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/weapon/zombie_claw/melee_attack_chain(mob/user, atom/target, params, rightclick)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.stat == DEAD)
			return
		human_target.reagents.add_reagent(/datum/reagent/zombium, zombium_per_hit)
	return ..()

/obj/item/weapon/zombie_claw/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if(!has_proximity)
		return
	if(!istype(target, /obj/machinery/door))
		return
	if(user.do_actions)
		return

	target.balloon_alert_to_viewers("prying open [target]...")
	if(!do_after(user, 4 SECONDS, IGNORE_HELD_ITEM, target))
		return
	var/obj/machinery/door/door = target
	playsound(user.loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	if(door.locked)
		to_chat(user, span_warning("\The [target] is bolted down tight."))
		return FALSE
	if(door.welded)
		to_chat(user, span_warning("\The [target] is welded shut."))
		return FALSE
	if(door.density) //Make sure it's still closed
		door.open(TRUE)

/obj/item/weapon/zombie_claw/strong
	force = 30

/obj/item/weapon/zombie_claw/tank
	attack_speed = 12
	force = 40

/obj/item/weapon/zombie_claw/no_zombium
	zombium_per_hit = 0
