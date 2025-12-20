/obj/item/clothing/suit/resin_bodysuit
	name = "living resin bodysuit"
	desc = "Living mass of tentacles pretty much, yuck."
	//get actual sprites.
	icon = 'ntf_modular/icons/obj/clothing/uniforms/uniforms.dmi'
	worn_icon_list = list(slot_w_uniform_str = 'ntf_modular/icons/mob/clothing/uniforms/marine_uniforms.dmi')
	icon_state = "sneak"
	color = COLOR_PURPLE
	equip_slot_flags = ITEM_SLOT_UNDERWEAR|ITEM_SLOT_ICLOTHING|ITEM_SLOT_OCLOTHING

/obj/item/clothing/suit/resin_bodysuit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parasitic_clothing)

/obj/item/storage/backpack/marine/resin_pack
	name = "living resin sack"
	desc = "A mass of resin and tentacles stuck to your back, weighting down."
	//get actual sprites.
	slowdown = 0.2
	var/evolve_timer

/obj/item/storage/backpack/marine/resin_pack/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/parasitic_clothing)

/obj/item/storage/backpack/marine/resin_pack/equipped(mob/user, slot)
	. = ..()
	if(!evolve_timer && (slot & ITEM_SLOT_BACK))
		evolve_timer = addtimer(CALLBACK(src ,PROC_REF(try_evolve), user), 3 MINUTES, TIMER_STOPPABLE)

/obj/item/storage/backpack/marine/resin_pack/proc/try_evolve(mob/living/carbon/human/victim)
	if(!victim)
		return
	var/datum/component/parasitic_clothing/ownparacomp = GetComponent(/datum/component/parasitic_clothing)
	var/obj/item/clothing/suit/resin_bodysuit/goobersuit = new /obj/item/clothing/suit/resin_bodysuit(loc)
	var/datum/component/parasitic_clothing/paracomp = goobersuit.GetComponent(/datum/component/parasitic_clothing)
	paracomp.hivenumber = ownparacomp.hivenumber
	if(victim.w_underwear)
		victim.dropItemToGround(victim.w_uniform)
	victim.visible_message(span_warning("[src] evolves and wraps itself around [victim]!"),
			span_warning("[src] evolves and wraps itself around your body!"),
			span_notice("You hear rustling."))
	victim.equip_to_slot_or_del(goobersuit, ITEM_SLOT_UNDERWEAR, TRUE)
	victim.dropItemToGround(src)
	qdel(src)


/obj/item/storage/backpack/marine/resin_pack/unequipped(mob/unequipper, slot)
	. = ..()
	deltimer(evolve_timer)
