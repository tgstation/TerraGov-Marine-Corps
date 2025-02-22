/datum/ai_behavior/human
	///Probability of trying to throw a grenade during process
	var/nade_throw_prop = 15
	///Chat lines for trying to heal
	var/list/nade_throw_chat = list("Grenade out!", "Fire in the hole!", "Grenade!", "Catch this!")

///Decides if we should throw a grenade
/datum/ai_behavior/human/proc/grenade_process()
	if(!combat_target)
		return
	if(!prob(nade_throw_prop))
		return
	if(!length(mob_inventory.grenade_list))
		return
	if(get_dist(mob_parent, combat_target) < 4) //lets not nade ourselves
		return
	if(!line_of_sight(mob_parent, combat_target, 7))
		return
	return throw_grenade(combat_target, get_grenade())

///Throws the grenade
/datum/ai_behavior/human/proc/throw_grenade(atom/target, obj/item/explosive/grenade/grenade)
	if(!grenade)
		return
	if(mob_parent.incapacitated() || mob_parent.lying_angle)
		return
	grenade.attack_self(mob_parent)
	if(prob(85))
		try_speak(pick(nade_throw_chat))
	return mob_parent.throw_item(target, grenade)

///Finds a suitable grenade to throw
/datum/ai_behavior/human/proc/get_grenade()
	var/list/nade_options = list()
	for(var/obj/item/explosive/grenade/option AS in mob_inventory.grenade_list)
		if(isgun(option.loc))
			continue
		var/mob/living/living_parent = mob_parent
		if(istype(option, /obj/item/explosive/grenade/smokebomb) && (living_parent.health <= minimum_health * 2 * living_parent.maxHealth))
			return
		nade_options += option

	return pick(nade_options)
