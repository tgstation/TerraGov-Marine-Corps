/obj/item/stack/spiketrap //A deployable spike trap, causes damage to anyone who steps over it
	name = "Spike trap assembly"
	desc = "An assortment of piercing spikes."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "barbed_wire"
	flags_item = NOBLUDGEON
	singular_name = "pile"
	w_class = WEIGHT_CLASS_SMALL
	force = 0
	attack_verb = list("hit", "whacked", "sliced")
	max_amount = 20
	merge_type = /obj/item/stack/spiketrap
	///The item this deploys into
	var/deployable_item = /obj/item/spiketrap
	///Time to deploy
	var/deploy_time = 1 SECONDS
	///Time to undeploy
	var/undeploy_time = 1 SECONDS
	///Whether it is wired
	var/is_wired = FALSE

/obj/item/stack/spiketrap/Initialize(mapload, new_amount)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, deploy_time, undeploy_time)


/obj/item/spiketrap
	name = "Spike trap assembly"
	desc = "An assortment of piercing spikes."
	icon = 'icons/Marine/marine-items.dmi'
	icon_state = "barbed_wire"

/obj/item/spiketrap/Initialize(mapload)
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_cross),
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/item/spiketrap/proc/on_cross(datum/source, atom/movable/victim, oldloc, oldlocs)
	if(!isliving(victim))
		return
	if(CHECK_MULTIPLE_BITFIELDS(victim.pass_flags, HOVERING))
		return
	var/mob/living/draggedmob = victim
	if(draggedmob.lying_angle) ///so dragged corpses don't trigger mines.
		return
	activate_trap(victim)

/obj/item/spiketrap/proc/activate_trap(mob/living/victim)
	var/mob/living/carbon/human/target = victim
	if(target.get_limb(LEGS))
		target.take_limb_damage(10)

/*
	if(!armed || triggered)
		return FALSE
	if((L.status_flags & INCORPOREAL))
		return FALSE
	var/obj/item/card/id/id = L.get_idcard()
	if(id?.iff_signal & iff_signal)
		return FALSE

	L.visible_message(span_danger("[icon2html(src, viewers(L))] \The [src] clicks as [L] moves in front of it."), \
	span_danger("[icon2html(src, viewers(L))] \The [src] clicks as you move in front of it."), \
	span_danger("You hear a click."))

	playsound(loc, 'sound/weapons/mine_tripped.ogg', 25, 1)
	INVOKE_ASYNC(src, PROC_REF(trigger_explosion))
	return TRUE
*/



/*
/obj/item/weapon/shield/riot/marine/deployable
	name = "\improper TL-182 deployable shield"
	desc = "A compact shield adept at blocking blunt or sharp objects from connecting with the shield wielder. Can be deployed as a barricade. Alt click to tighten the strap."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "folding_shield"
	flags_equip_slot = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	max_integrity = 300
	integrity_failure = 50
	soft_armor = list(MELEE = 35, BULLET = 30, LASER = 20, ENERGY = 40, BOMB = 25, BIO = 50, FIRE = 0, ACID = 30)
	slowdown = 0.3
	flags_item = IS_DEPLOYABLE
	///The item this deploys into
	var/deployable_item = /obj/structure/barricade/metal/deployable
	///Time to deploy
	var/deploy_time = 1 SECONDS
	///Time to undeploy
	var/undeploy_time = 1 SECONDS
	///Whether it is wired
	var/is_wired = FALSE

/obj/item/weapon/shield/riot/marine/deployable/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable_item, deployable_item, deploy_time, undeploy_time)

/obj/item/weapon/shield/riot/marine/deployable/set_shield()
	AddComponent(/datum/component/shield, SHIELD_PARENT_INTEGRITY, shield_cover = list(MELEE = 40, BULLET = 35, LASER = 35, ENERGY = 35, BOMB = 40, BIO = 15, FIRE = 30, ACID = 35))
*/

