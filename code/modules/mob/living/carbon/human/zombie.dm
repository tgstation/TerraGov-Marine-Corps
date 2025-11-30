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
	var/zombium_per_hit = 9

/obj/item/weapon/zombie_claw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)

/obj/item/weapon/zombie_claw/melee_attack_chain(mob/user, atom/target, params, rightclick)
	..()
	if(!user.lying_angle)
		target.attack_zombie(user, src, params, rightclick)

/obj/item/weapon/zombie_claw/strong
	force = 30

/obj/item/weapon/zombie_claw/tank
	attack_speed = 12
	force = 40

/obj/item/weapon/zombie_claw/no_zombium
	zombium_per_hit = 0

/**
 * Any special attack by zombie behavior
 * Return FALSE if normal melee_attack_chain should occur
*/
/atom/proc/attack_zombie(mob/living/carbon/human/zombie, obj/item/weapon/zombie_claw/claw, params, rightclick)
	return FALSE

/obj/machinery/door/attack_zombie(mob/living/carbon/human/zombie, obj/item/weapon/zombie_claw/claw, params, rightclick)
	if(!density)
		return
	if(zombie.do_actions)
		return
	if(locked)
		to_chat(zombie, span_warning("\The [src] is bolted down tight."))
		return
	if(welded)
		to_chat(zombie, span_warning("\The [src] is welded shut."))
		return

	balloon_alert_to_viewers("prying open [src]...")
	if(!do_after(zombie, 4 SECONDS, IGNORE_HELD_ITEM, src))
		return
	playsound(zombie.loc, 'sound/effects/metal_creaking.ogg', 25, 1)

	if(!density || operating) //Make sure it's still closed
		return
	zombie.changeNext_move(claw.attack_speed)
	open(TRUE)
	return TRUE

/obj/machinery/power/apc/attack_zombie(mob/living/carbon/human/zombie, obj/item/weapon/zombie_claw/claw, params, rightclick)
	zombie.do_attack_animation(src, ATTACK_EFFECT_CLAW)
	zombie.visible_message(span_danger("[zombie] slashes \the [src]!"), \
	span_danger("We slash \the [src]!"), null, 5)
	playsound(loc, SFX_ALIEN_CLAW_METAL, 25, 1)

	var/allcut = wires.is_all_cut()

	if(beenhit >= pick(3, 4) && !CHECK_BITFIELD(machine_stat, PANEL_OPEN))
		ENABLE_BITFIELD(machine_stat, PANEL_OPEN)
		update_appearance()
		visible_message(span_danger("\The [src]'s cover swings open, exposing the wires!"), null, null, 5)

	else if(CHECK_BITFIELD(machine_stat, PANEL_OPEN) && !allcut)
		wires.cut_all()
		update_appearance()
		visible_message(span_danger("\The [src]'s wires snap apart in a rain of sparks!"), null, null, 5)
	else
		beenhit += 1
	zombie.changeNext_move(claw.attack_speed)
	zombie.do_attack_animation(src, used_item = claw)
	return TRUE

/obj/machinery/nuclearbomb/attack_zombie(mob/living/carbon/human/zombie, obj/item/weapon/zombie_claw/claw, params, rightclick)
	if(!timer_enabled)
		to_chat(zombie, span_warning("\The [name] isn't active."))
		return

	zombie.visible_message(span_boldwarning("[zombie.name] begins to slash at the nuke."),
	"Starts slashing at the nuke.")
	if(!do_after(zombie, 5 SECONDS, NONE, src, BUSY_ICON_DANGER, BUSY_ICON_HOSTILE))
		return
	do_defuse(zombie)

/mob/living/carbon/human/attack_zombie(mob/living/carbon/human/zombie, obj/item/weapon/zombie_claw/claw, params, rightclick)
	. = FALSE
	if(stat == DEAD)
		return
	var/parrychance = 20
	if(is_holding_item_of_type(/obj/item/weapon/shield))
		parrychance = 40
		//pretty much all melee weapons and shield.
	if((is_holding_item_of_type(/obj/item/weapon/sword)\
			|| is_holding_item_of_type(/obj/item/weapon/twohanded) || is_holding_item_of_type(/obj/item/weapon/combat_knife)\
			|| is_holding_item_of_type(/obj/item/weapon/shield) || is_holding_item_of_type(/obj/item/weapon/baton)\
			|| is_holding_item_of_type(/obj/item/weapon/energy)) && prob(parrychance))
		visible_message("[src] blocks the attack by [zombie]!")
		playsound(loc, 'sound/effects/metalhit.ogg', 50)
		return TRUE

	if(!claw.zombium_per_hit)
		return
	reagents.add_reagent(/datum/reagent/zombium, modify_by_armor(claw.zombium_per_hit, BIO, 0, zombie.get_limbzone_target()))

/obj/structure/barricade/attack_zombie(mob/living/carbon/human/zombie, obj/item/weapon/zombie_claw/claw, params, rightclick)
	if(!is_wired)
		return
	balloon_alert(zombie, "barbed wire slices into you!")
	zombie.apply_damage(40, blocked = MELEE , sharp = TRUE, updating_health = TRUE)//Higher damage since zombies have high healing rate, and theyre using their hands
