/obj/structure/xeno/resin_stew_pod
	name = "ambrosia jelly pot"
	desc = "A large pot of thick viscious liquid churning together endlessly into large mounds of incredibly valuable, golden jelly."
	icon = 'ntf_modular/icons/xeno/resin_pod.dmi'
	icon_state = "stewpod"
	density = FALSE
	opacity = FALSE
	anchored = TRUE
	max_integrity = 250
	layer = BELOW_OBJ_LAYER
	pixel_x = -16
	pixel_y = -16
	xeno_structure_flags = IGNORE_WEED_REMOVAL
	hit_sound = SFX_ALIEN_RESIN_MOVE
	destroy_sound = SFX_ALIEN_RESIN_MOVE
	///How many actual jellies the pod has stored
	var/chargesleft = 0
	///Max amount of jellies the pod can hold
	var/maxcharges = 20
	///Slowprocess ticks of progress towards next jelly
	var/jelly_progress = 0
	///info to add to desc, updated by process()
	var/extra_desc
	///ckey of the player that created it
	var/creator_ckey
	///Slowprocess ticks without suitable owner
	var/decay = 0

/obj/structure/xeno/resin_stew_pod/Initialize(mapload, _hivenumber)
	. = ..()
	GLOB.hive_datums[hivenumber].req_jelly_pods += src
	START_PROCESSING(SSslowprocess, src)
	SSminimaps.add_marker(src, ((MINIMAP_FLAG_ALL) ^ (MINIMAP_FLAG_SURVIVOR)), image('ntf_modular/icons/UI_icons/map_blips.dmi', null, "ambrosia", MINIMAP_LABELS_LAYER))

/obj/structure/xeno/resin_stew_pod/Destroy()
	STOP_PROCESSING(SSslowprocess, src)
	return ..()

/obj/structure/xeno/resin_stew_pod/examine(mob/user, distance, infix, suffix)
	. = ..()
	if(extra_desc)
		. += extra_desc
	var/mob/living/carbon/xenomorph/creator = GLOB.mobs_by_ckey_list[creator_ckey]
	if(isobserver(creator))
		var/mob/dead/observer/ghost_creator = creator
		creator = ghost_creator.can_reenter_corpse?.resolve()
	if(!isxeno(creator) || !issamexenohive(creator))
		return
	else
		. += "It belongs to [creator]."

/obj/structure/xeno/resin_stew_pod/process()
	var/mob/living/carbon/xenomorph/creator = GLOB.mobs_by_ckey_list[creator_ckey]
	if(isobserver(creator))
		var/mob/dead/observer/ghost_creator = creator
		creator = ghost_creator.can_reenter_corpse?.resolve()
	if(!isxeno(creator) || !issamexenohive(creator) || creator.stat == DEAD || !(creator.client) || (creator.client.inactivity > 15 MINUTES))
		if(decay >= 180) //15 minutes without a suitable owner will destroy it
			qdel(src)
			return
		extra_desc = "It has [chargesleft] jelly globules remaining and appears to be decaying."
		decay++
		return
	decay = max(0, decay - 5)
	var/progress_needed = GLOB.hive_datums[hivenumber].req_jelly_progress_required
	if(chargesleft < maxcharges)
		if(jelly_progress <= progress_needed)
			jelly_progress++
		else
			jelly_progress = 0
			chargesleft++
	if(chargesleft < maxcharges)
		extra_desc = "It has [chargesleft] jelly globules remaining and will create a new jelly in [(progress_needed - jelly_progress)*5] seconds"
	else
		extra_desc = "It has [chargesleft] jelly globules remaining and seems latent."

/obj/structure/xeno/resin_stew_pod/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage * xeno_attacker.xeno_melee_damage_modifier, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(xeno_attacker.status_flags & INCORPOREAL)
		return FALSE

	if(issamexenohive(xeno_attacker))
		if(xeno_attacker.a_intent == INTENT_HARM && (xeno_attacker.xeno_flags & XENO_DESTROY_OWN_STRUCTURES))
			balloon_alert(xeno_attacker, "Destroying...")
			if(do_after(xeno_attacker, HIVELORD_TUNNEL_DISMANTLE_TIME, IGNORE_HELD_ITEM, src, BUSY_ICON_BUILD))
				deconstruct(FALSE)
			return

	if(!issamexenohive(xeno_attacker) && xeno_attacker.a_intent == INTENT_HARM)
		return ..()

	do
		if(!(chargesleft > 0))
			balloon_alert(xeno_attacker, "No jelly remaining")
			to_chat(xeno_attacker, span_xenonotice("We reach into \the [src], but only find dregs of resin. We should wait some more.") )
			return

		balloon_alert(xeno_attacker, "Retrieved jelly")
		new /obj/item/resin_jelly/req_jelly(xeno_attacker.loc, hivenumber)
		chargesleft--
	while(do_mob(xeno_attacker, src, 1 SECONDS))

/obj/structure/xeno/resin_stew_pod/Destroy()
	if(loc && (chargesleft > 0))
		for(var/i = 1 to chargesleft)
			if(prob(95))
				new /obj/item/resin_jelly/req_jelly(loc, hivenumber)
	GLOB.hive_datums[hivenumber].req_jelly_pods -= src
	. = ..()

///////////////////////
/// Requisition Jelly//
///////////////////////

/obj/item/resin_jelly/req_jelly
	name = "alien ambrosia"
	desc = "A beautiful, glittering mound of honey like resin, might fetch a good price."
	icon = 'ntf_modular/icons/xeno/xeno_materials.dmi'
	icon_state = "reqjelly"
	w_class = WEIGHT_CLASS_TINY // 100 can fit into a box, transport by satchel is trivial
	// Could consider giving it different soft_armor values than regular resin jelly?
	// Currently does everything resin jelly does, so it might need custom code for doing anything special
