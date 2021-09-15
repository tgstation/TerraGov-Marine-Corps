/datum/species/husk
	name = "Husk"
	name_plural = "Husks"
	icobase = 'icons/mob/human_races/r_husk.dmi'
	deform = 'icons/mob/human_races/r_husk.dmi'
	total_health = 125
	species_flags = NO_BREATHE|NO_SCAN|NO_BLOOD|NO_POISON|NO_PAIN|NO_CHEM_METABOLIZATION|NO_STAMINA|HAS_UNDERWEAR|HEALTH_HUD_ALWAYS_DEAD|PARALYSE_RESISTANT
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	see_in_dark = 8
	blood_color = "#110a0a"
	hair_color = "#000000"
	slowdown = 0.5
	default_language_holder = /datum/language_holder/husk
	has_organ = list(
		"heart" =    /datum/internal_organ/heart,
		"lungs" =    /datum/internal_organ/lungs,
		"liver" =    /datum/internal_organ/liver,
		"kidneys" =  /datum/internal_organ/kidneys,
		"brain" =    /datum/internal_organ/brain/husk,
		"appendix" = /datum/internal_organ/appendix,
		"eyes" =     /datum/internal_organ/eyes
	)
	///Sounds made randomly by the husk
	var/list/sounds = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')
	///Time before resurrecting if dead
	var/revive_time = 1 MINUTES
	///How much burn and burn damage can you heal every Life tick (half a sec)
	var/heal_rate = 5

/datum/species/husk/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.faction = FACTION_XENO
	H.language_holder = new default_language_holder()
	H.setOxyLoss(0)
	H.setToxLoss(0)
	H.setCloneLoss(0)
	H.dropItemToGround(H.r_hand)
	H.dropItemToGround(H.l_hand)
	if(istype(H.wear_id, /obj/item/card/id))
		var/obj/item/card/id/id = H.wear_id
		id.access = list() // A bit gamey, but let's say ids have a security against husks
		id.iff_signal = NONE
	H.equip_to_slot_or_del(new /obj/item/weapon/husk_claw, SLOT_R_HAND)
	H.equip_to_slot_or_del(new /obj/item/weapon/husk_claw, SLOT_L_HAND)

	H.job = new /datum/job/husk //Prevent from skewing the respawn timer if you take a husk, it's a ghost role after all
	//remove larva
	var/obj/item/alien_embryo/alien_embryo = locate() in src
	for(var/datum/action/action AS in H.actions)
		action.remove_action(H)
	if(alien_embryo)
		qdel(alien_embryo)
		return

/datum/species/husk/handle_unique_behavior(mob/living/carbon/human/H)
	if(prob(10))
		playsound(get_turf(H), pick(sounds), 50)
	for(var/datum/limb/limb AS in H.limbs) //Regrow some limbs
		if(limb.limb_status & LIMB_DESTROYED && !(limb.parent?.limb_status & LIMB_DESTROYED) && prob(10))
			limb.remove_limb_flags(LIMB_DESTROYED)
			H.update_body()

	if(H.health != total_health)
		H.heal_limbs(heal_rate)

	for(var/organ_slot in has_organ)
		var/datum/internal_organ/internal_organ = H.internal_organs_by_name[organ_slot]
		internal_organ?.heal_organ_damage(1)
	H.updatehealth()

/datum/species/husk/handle_death(mob/living/carbon/human/H)
	SSmobs.stop_processing(H)
	if(!H.on_fire && H.has_working_organs())
		addtimer(CALLBACK(H, /mob/living/carbon/human.proc/revive_to_crit, TRUE, FALSE), revive_time)

/datum/species/husk/create_organs(mob/living/carbon/human/organless_human)
	. = ..()
	for(var/datum/limb/limb AS in organless_human.limbs)
		if(!istype(limb, /datum/limb/head))
			continue
		limb.vital = FALSE
		return

/obj/item/weapon/husk_claw
	name = "claws"
	hitsound = 'sound/weapons/slice.ogg'
	icon_state = ""
	force = 20
	sharp = IS_SHARP_ITEM_BIG
	edge = TRUE
	attack_verb = list("clawed", "slashed", "torn", "ripped", "diced", "cut", "bit")
	flags_item = NODROP|CAN_BUMP_ATTACK|DELONDROP
	attack_speed = 8 //Same as unarmed delay
	pry_capable = IS_PRY_CAPABLE_FORCE
	///How much zombium are transferred per hit. Set to zero to remove transmission
	var/zombium_per_hit = 5

/obj/item/weapon/husk_claw/melee_attack_chain(mob/user, atom/target, params, rightclick)
	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.stat == DEAD)
			return
		human_target.reagents.add_reagent(/datum/reagent/zombium, zombium_per_hit)
	return ..()

/obj/item/weapon/husk_claw/afterattack(atom/target, mob/user, has_proximity, click_parameters)
	. = ..()
	if(!istype(target, /obj/machinery/door/airlock))
		return
	if(user.do_actions)
		return

	target.balloon_alert_to_viewers("[user] starts to open [target]", "You start to pry open [target]")
	if(!do_after(user, 4 SECONDS, FALSE, target))
		return
	var/obj/machinery/door/airlock/door = target
	playsound(user.loc, 'sound/effects/metal_creaking.ogg', 25, 1)
	if(door.locked)
		to_chat(user, span_warning("\The [target] is bolted down tight."))
		return FALSE
	if(door.welded)
		to_chat(user, span_warning("\The [target] is welded shut."))
		return FALSE
	if(door.density) //Make sure it's still closed
		door.open(TRUE)

/datum/species/husk/fast
	name = "Fast husk"
	slowdown = 0

/datum/species/husk/tank
	name = "Tank husk"
	slowdown = 1
	heal_rate = 10
	total_health = 250
