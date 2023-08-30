/obj/item/stack/spiketrap //A deployable spike trap, causes damage to anyone who steps over it
	name = "Spike trap assembly"
	desc = "An assortment of piercing spikes."
	icon = 'icons/Marine/traps.dmi'
	icon_state = "spiketrap"
	flags_item = NOBLUDGEON
	singular_name = "pile"
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	attack_verb = list("hit", "whacked", "sliced")
	max_amount = 20
	merge_type = /obj/item/stack/spiketrap
	max_integrity = 200
	///The item this deploys into
	var/deployable_item = /obj/structure/spiketrap
	///Time to deploy
	var/deploy_time = 1 SECONDS
	///Time to undeploy
	var/undeploy_time = 1 SECONDS

/obj/item/stack/spiketrap/Initialize(mapload, new_amount)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, deploy_time, undeploy_time)

/obj/structure/spiketrap ///The actual deployed trap
	name = "Spike trap assembly"
	desc = "An assortment of piercing spikes."
	icon = 'icons/Marine/traps.dmi'
	icon_state = "spiketrap"
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	allow_pass_flags = PASS_MOB
	max_integrity = 200
	///How much damage the spikes do when you step on them
	var/spike_damage = 10

/obj/structure/spiketrap/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)

///Xenos get slashed when they attack this
/obj/structure/spiketrap/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	X.apply_damage(spike_damage*1.5, blocked = MELEE, updating_health = TRUE) //About a third as damaging as actually entering
	update_icon()
	return ..()

///When a mob passes over the turf where the trap is deployed
/obj/structure/spiketrap/proc/on_cross(datum/source, atom/movable/victim, oldloc, oldlocs)
	if(!isliving(victim))
		return
	if(CHECK_MULTIPLE_BITFIELDS(victim.pass_flags, HOVERING))
		return
	var/mob/living/draggedmob = victim
	if(draggedmob.lying_angle) //so dragged corpses don't die from being dragged through a spike field.
		return
	apply_damage(victim)

///Actually taking slowdown and damage from the trap
/obj/structure/spiketrap/proc/apply_damage(mob/living/victim)
	victim.apply_status_effect(/datum/status_effect/incapacitating/harvester_slowdown, 3) //Moving through spikes slows you down
	if(isxeno(victim))
		victim.apply_damage(spike_damage * 3, BRUTE, updating_health = TRUE)

	var/mob/living/carbon/human/target = victim
	if(target.get_limb(BODY_ZONE_PRECISE_L_FOOT) || target.get_limb(BODY_ZONE_PRECISE_R_FOOT))
		for(var/limb_to_hit in list(BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
			target.apply_damage(spike_damage, BRUTE, limb_to_hit, updating_health = TRUE)

	playsound(src, 'sound/weapons/bladeslice.ogg', 50)

/obj/item/stack/speartrap //A deployable spear trap, causes damage to anyone who walks into it
	name = "Spear trap assembly"
	desc = "An deployable wall of spears."
	icon = 'icons/Marine/trap_spear.dmi'
	icon_state = "speartrap"
	flags_item = NOBLUDGEON
	singular_name = "pile"
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	attack_verb = list("hit", "whacked", "sliced")
	max_amount = 20
	merge_type = /obj/item/stack/speartrap
	///The item this deploys into
	var/deployable_item = /obj/structure/speartrap
	///Time to deploy
	var/deploy_time = 1 SECONDS
	///Time to undeploy
	var/undeploy_time = 1 SECONDS
	///Used for the health of the spear
	max_integrity = 200

/obj/item/stack/speartrap/Initialize(mapload, new_amount)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, deploy_time, undeploy_time)

/obj/structure/speartrap ///The actual deployed trap
	name = "Deployed Spear"
	desc = "A very pointy stick, dont walk into it... please."
	icon = 'icons/Marine/trap_spear.dmi'
	icon_state = "speartrap"
	pixel_x = -13
	pixel_y = -9 //Don't touch the offsets unless you intend on respriting these
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	///How much damage the spear does when you walk into it
	var/trap_damage = 15
	///Used for the health of the spear
	max_integrity = 200

/obj/structure/speartrap/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_BUMPED, PROC_REF(on_bump))

///Xenos get slashed when they attack this
/obj/structure/speartrap/attack_alien(mob/living/carbon/xenomorph/X, damage_amount, damage_type, damage_flag, effects, armor_penetration, isrightclick)
	if(X.status_flags & INCORPOREAL)
		return FALSE

	if(get_dir(src, X) == dir) //You only get hurt if you attack the pointy end
		X.apply_damage(trap_damage*5, blocked = MELEE, updating_health = TRUE)
	update_icon()
	return ..()

///When a mob bumps into the speartrap
/obj/structure/speartrap/proc/on_bump(datum/source, atom/movable/victim, oldloc, oldlocs)
	if(!isliving(victim))
		return

	if(get_dir(src, victim) == dir)
		apply_damage(victim)

///Actually taking stun and damage from the trap
/obj/structure/speartrap/proc/apply_damage(mob/living/victim)
	if(isxeno(victim))
		victim.apply_damage(trap_damage * 5, BRUTE, updating_health = TRUE)

	victim.apply_damage(trap_damage, BRUTE, updating_health = TRUE)
	victim.apply_status_effect(/datum/status_effect/incapacitating/immobilized, 1 SECONDS) //Punishing, but also prevents instadeath

	playsound(src, 'sound/weapons/bladeslice.ogg', 50)

