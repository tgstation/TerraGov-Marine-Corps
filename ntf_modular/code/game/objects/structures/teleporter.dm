/obj/item/teleporter_kit/premade
	item_flags = IS_DEPLOYABLE|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP

/obj/item/teleporter_kit/premade/Initialize(mapload)
	.=..()
	if(item_flags & IS_DEPLOYED)
		loc.name = name

GLOBAL_LIST_INIT(remotely_linked_teleporter_pairs, list())

/obj/effect/remote_teleporter_linker
	name = "Remote Teleporter Pair Linker"
	var/id = "Teleporter Pair"

/obj/effect/remote_teleporter_linker/Initialize(mapload)
	..()
	. = INITIALIZE_HINT_QDEL
	var/obj/item/teleporter_kit/kit = locate() in loc

	if(!kit)
		var/obj/machinery/deployable/teleporter/teleporter = locate() in loc
		kit = teleporter?.get_internal_item()

	if(!kit)
		qdel(src)
		CRASH("remote_teleporter_linker at [logdetails(src)] with id [id] has no teleporter kit in its loc!")

	switch(LAZYLEN(GLOB.remotely_linked_teleporter_pairs[id]))
		if(0)
			GLOB.remotely_linked_teleporter_pairs[id] = list(kit)
		if(1)
			var/obj/item/teleporter_kit/premade/to_link = GLOB.remotely_linked_teleporter_pairs[id][1]
			to_link.set_linked_teleporter(kit)
			kit.set_linked_teleporter(to_link)
			GLOB.remotely_linked_teleporter_pairs[id] += kit
		else
			GLOB.remotely_linked_teleporter_pairs[id] += kit
			var/crash_message = "Teleporter pair with id [id] has three or more elements! ("
			var/list/bad_kit_messages = list()
			for(var/bad_kit in GLOB.remotely_linked_teleporter_pairs[id])
				bad_kit_messages += "\[[logdetails(bad_kit)]\]"
			crash_message += bad_kit_messages.Join(",")
			crash_message += ")"
			qdel(src)
			CRASH(crash_message)

/obj/effect/remote_teleporter_linker/pair1
	name = "Remote Teleporter Pair Linker - Pair 1"
	id = "Teleporter Pair 1"

/obj/effect/remote_teleporter_linker/pair2
	name = "Remote Teleporter Pair Linker - Pair 2"
	id = "Teleporter Pair 2"

/obj/effect/remote_teleporter_linker/pair3
	name = "Remote Teleporter Pair Linker - Pair 3"
	id = "Teleporter Pair 3"

/obj/effect/remote_teleporter_linker/pair4
	name = "Remote Teleporter Pair Linker - Pair 4"
	id = "Teleporter Pair 4"

/obj/machinery/deployable/teleporter/disassemble(mob/user)
	var/obj/item/teleporter_kit/kit = get_internal_item()
	log_combat(user, src, "deconstructed", addition=" linked teleporter is \[[logdetails(kit?.linked_teleporter)]\]")
	. = ..()

/obj/machinery/deployable/teleporter/hitby(atom/movable/AM, speed = 5)
	var/obj/item/teleporter_kit/kit = get_internal_item()
	. = ..()
	log_combat(AM.thrower, src, "thrown at", AM, " linked teleporter is \[[logdetails(kit?.linked_teleporter)]\]")

/obj/machinery/deployable/teleporter/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = 0)
	var/obj/item/teleporter_kit/kit = get_internal_item()
	. = ..()
	log_combat(user, src, "attacked", "(DAMTYPE: [uppertext(damage_type)]) (RAW DMG: [damage_amount]), linked teleporter is \[[logdetails(kit?.linked_teleporter)]\]")

/obj/machinery/deployable/teleporter/bullet_act(atom/movable/projectile/proj)
	var/obj/item/teleporter_kit/kit = get_internal_item()
	. = ..()
	log_combat(proj.firer, src, "shot", proj, " linked teleporter is \[[logdetails(kit?.linked_teleporter)]\]")

/obj/item/teleporter_kit/hitby(atom/movable/AM, speed = 5)
	. = ..()
	log_combat(AM.thrower, src, "thrown at", AM, " linked teleporter is \[logdetails(linked_teleporter)]\]")


/obj/item/teleporter_kit/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = 0)
	. = ..()
	log_combat(user, src, "attacked", "(DAMTYPE: [uppertext(damage_type)]) (RAW DMG: [damage_amount]) in linked teleporter is \[[logdetails(linked_teleporter)]\]")


/obj/item/teleporter_kit/bullet_act(atom/movable/projectile/proj)
	. = ..()
	log_combat(proj.firer, src, "shot", proj, " linked teleporter is \[[logdetails(linked_teleporter)]\]")

/obj/item/teleporter_kit/indestructible
	name = "\improper ASRS Reinforced Bluespace teleporter"
	resistance_flags = RESIST_ALL

/obj/item/teleporter_kit/indestructible/Initialize(mapload)
	. = ..()
	name = "\improper ASRS Reinforced Bluespace teleporter #[self_tele_tag]"

/obj/item/teleporter_kit/indestructible/toggle_deployment_flag(deployed)
	. = ..()
	if(deployed)
		var/obj/machinery/deployable/teleporter/deployed_tele = loc
		if(!istype(deployed_tele))
			CRASH("Teleporter kit deployed to wrong type")
		deployed_tele.resistance_flags = RESIST_ALL

/obj/effect/teleporter_linker/indestructible/Initialize(mapload, skip)
	if(skip > 0)
		skip--
		return ..()
	skip++
	. = ..()
	var/obj/item/teleporter_kit/indestructible/teleporter_a = new(loc)
	var/obj/item/teleporter_kit/indestructible/teleporter_b = new(loc)
	teleporter_a.set_linked_teleporter(teleporter_b)
	teleporter_b.set_linked_teleporter(teleporter_a)
	log_combat(src,teleporter_a,"linked",object=teleporter_b)
	qdel(src)

/obj/machinery/deployable/teleporter/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage * xeno_attacker.xeno_melee_damage_modifier, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	attack_hand(xeno_attacker)
