/datum/species/zombie
	name = "Zombie"
	icobase = 'icons/mob/human_races/r_husk.dmi'
	total_health = 125
	species_flags = NO_BREATHE|NO_SCAN|NO_BLOOD|NO_POISON|NO_PAIN|NO_CHEM_METABOLIZATION|NO_STAMINA|HEALTH_HUD_ALWAYS_DEAD|PARALYSE_RESISTANT|SPECIES_NO_HUG
	lighting_cutoff = LIGHTING_CUTOFF_HIGH
	inherent_traits = TRAIT_CRIT_IS_DEATH //so they dont stay alive when downed ig.
	blood_color = "#110a0a"
	hair_color = "#000000"
	slowdown = 0.5
	default_language_holder = /datum/language_holder/zombie
	has_organ = list(
		"heart" = /datum/internal_organ/heart,
		"lungs" = /datum/internal_organ/lungs,
		"liver" = /datum/internal_organ/liver,
		"kidneys" = /datum/internal_organ/kidneys,
		"brain" = /datum/internal_organ/brain/zombie,
		"appendix" = /datum/internal_organ/appendix,
		"eyes" = /datum/internal_organ/eyes
	)
	death_message = "seizes up and falls limp..."
	///Sounds made randomly by the zombie
	var/list/sounds = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg','sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')

	///Time before resurrecting if dead
	var/revive_time = 1 MINUTES

	///How much burn and burn damage can you heal every Life tick (half a sec)
	var/heal_rate = 10
	var/faction = FACTION_ZOMBIE
	var/hivenumber = FACTION_ZOMBIE
	var/claw_type = /obj/item/weapon/zombie_claw
	///Whether this zombie type can jump
	var/can_jump = FALSE
	///List of special actions given by this species
	var/list/action_list
	///Counting whether they are designated as unrevivable for stats
	var/perma = FALSE

/datum/species/zombie/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.set_undefibbable()
	H.faction = faction
	H.transfer_to_hive(hivenumber)
	H.language_holder = new default_language_holder()
	H.setOxyLoss(0)
	H.setToxLoss(0)
	H.setCloneLoss(0)
	H.dropItemToGround(H.r_hand, TRUE)
	H.dropItemToGround(H.l_hand, TRUE)
	H.dextrous = FALSE//Prevents from opening cades
	if(SSticker.mode.zombie_ids)
		if(istype(H.wear_id, /obj/item/card/id))
			var/obj/item/card/id/id = H.wear_id
			id.access = list() // A bit gamey, but let's say ids have a security against zombies
			id.iff_signal = NONE
	else
		if(H.wear_id)
			H.dropItemToGround(H.wear_id, TRUE)
	H.equip_to_slot_or_del(new claw_type, SLOT_R_HAND)
	H.equip_to_slot_or_del(new claw_type, SLOT_L_HAND)
	var/datum/atom_hud/health_hud = GLOB.huds[DATA_HUD_MEDICAL_OBSERVER]
	health_hud.add_hud_to(H)
	H.job = SSjob.type_occupations[/datum/job/zombie] //Prevent from skewing the respawn timer if you take a zombie, it's a ghost role after all
	for(var/datum/action/action AS in H.actions)
		action.remove_action(H)
	var/datum/action/rally_zombie/rally_zombie = new
	rally_zombie.give_action(H)
	var/datum/action/set_agressivity/set_zombie_behaviour = new
	set_zombie_behaviour.give_action(H)
	if(can_jump)
		H.set_jump_component(cost = 0)

	var/datum/action/minimap/zombie/mini = new
	mini.give_action(H)
	SSminimaps.add_marker(H, MINIMAP_FLAG_ZOMBIE, image('icons/UI_icons/map_blips.dmi', null, "pmc2", MINIMAP_BLIPS_LAYER))
	H.transfer_to_hive(FACTION_ZOMBIE)

	for(var/action_type in action_list)
		var/datum/action/action = new action_type()
		action.give_action(H)

/datum/species/zombie/post_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/atom_hud/health_hud = GLOB.huds[DATA_HUD_MEDICAL_OBSERVER]
	health_hud.remove_hud_from(H)
	qdel(H.r_hand)
	qdel(H.l_hand)
	for(var/datum/action/action AS in H.actions)
		action.remove_action(H)
	if(can_jump)
		H.set_jump_component()

/datum/species/zombie/handle_unique_behavior(mob/living/carbon/human/H)
	if(prob(10))
		playsound(get_turf(H), pick(sounds), 50)



	if(SSticker.mode.zombies_regrow_limbs)
		var/datum/limb/limb = pick(H.limbs) //small chance of regrowing a limb
		if(limb.limb_status & LIMB_DESTROYED && !(limb.parent?.limb_status & LIMB_DESTROYED) && prob(1))
			limb.remove_limb_flags(LIMB_DESTROYED)
			if(istype(limb, /datum/limb/hand/l_hand))
				H.equip_to_slot_or_del(new claw_type, SLOT_L_HAND)
			else if (istype(limb, /datum/limb/hand/r_hand))
				H.equip_to_slot_or_del(new claw_type, SLOT_R_HAND)
			H.update_body()
		else if(limb.limb_status & LIMB_BROKEN && prob(0.5))
			limb.remove_limb_flags(LIMB_BROKEN | LIMB_SPLINTED | LIMB_STABILIZED)
	else
		if(HAS_TRAIT_FROM(H, TRAIT_FLOORED, TRAIT_LEGLESS))
			//self-destruct if neutralized
			H.remove_organ_slot(ORGAN_SLOT_HEART)
			H.death()
			return
		var/numhands = 0
		var/datum/limb/temp = H.get_limb("l_hand")
		if(temp && temp.is_usable())
			numhands++
		temp = H.get_limb("r_hand")
		if(temp && temp.is_usable())
			numhands++
		if(!numhands)
			//self-destruct if neutralized
			H.remove_organ_slot(ORGAN_SLOT_HEART)
			H.death()
			return

	if(H.buckled && prob(1)) //small chance of escapting a nest
		H.buckled.unbuckle_mob(src)

	if(H.health != total_health)
		H.heal_limbs(heal_rate)

	for(var/organ_slot in has_organ)
		var/datum/internal_organ/internal_organ = H.get_organ_slot(organ_slot)
		internal_organ?.heal_organ_damage(1)
	H.updatehealth()

/datum/species/zombie/handle_death(mob/living/carbon/human/H)
	var/datum/limb/head/head = H.get_limb("head")
	if(H.on_fire)
		addtimer(CALLBACK(src, PROC_REF(fade_out_and_qdel_in), H), 1 MINUTES)
		return
	if(!H.has_working_organs() || (head.limb_status & LIMB_DESTROYED))
		SSmobs.stop_processing(H) // stopping the processing extinguishes the fire that is already on, to stop from doubling up
		addtimer(CALLBACK(src, PROC_REF(fade_out_and_qdel_in), H), 1 MINUTES)
		return
	addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, revive_to_crit), TRUE, FALSE), revive_time)


/datum/species/zombie/create_organs(mob/living/carbon/human/organless_human)
	. = ..()
	for(var/datum/limb/limb AS in organless_human.limbs)
		if(!istype(limb, /datum/limb/head))
			continue
		limb.vital = TRUE
		return

/datum/species/zombie/can_revive_to_crit(mob/living/carbon/human/human)
	var/datum/limb/head/head = human.get_limb("head")
	if((!SSticker.mode?.zombie_rebirth) || human.on_fire || !human.has_working_organs() || (head.limb_status & LIMB_DESTROYED) || isspaceturf(get_turf(human)))
		SSmobs.stop_processing(human)
		addtimer(CALLBACK(src, PROC_REF(fade_out_and_qdel_in), human), 20 SECONDS)
		return FALSE
	return TRUE

/// We start fading out the human and qdel them in set time
/datum/species/zombie/proc/fade_out_and_qdel_in(mob/living/carbon/human/H, time = 5 SECONDS)
	GLOB.round_statistics.zombies_permad++
	fade_out(H)
	QDEL_IN(H, time)

/datum/species/zombie/fast
	name = "Fast zombie"
	slowdown = 0
	can_jump = TRUE

/datum/species/zombie/fast/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.transform = matrix().Scale(0.8, 0.8)

/datum/species/zombie/fast/post_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.transform = matrix().Scale(1/(0.8), 1/(0.8))

/datum/species/zombie/tank
	name = "Tank zombie"
	slowdown = 1
	heal_rate = 30
	total_health = 350
	claw_type = /obj/item/weapon/zombie_claw/tank

/datum/species/zombie/tank/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.transform = matrix().Scale(1.2, 1.2)
	ADD_TRAIT(H, TRAIT_STUNIMMUNE, ZOMBIE_TRAIT)
	H.move_resist = MOVE_FORCE_EXCEPTIONALLY_STRONG

/datum/species/zombie/tank/post_species_loss(mob/living/carbon/human/H)
	. = ..()
	H.transform = matrix().Scale(1/(1.2), 1/(1.2))
	REMOVE_TRAIT(H, TRAIT_STUNIMMUNE, ZOMBIE_TRAIT)
	H.move_resist = initial(H.move_resist)

/datum/species/zombie/strong
	name = "Strong zombie" //These are zombies created from marines, they are stronger, but of course rarer
	slowdown = -0.5
	heal_rate = 20
	total_health = 200
	claw_type = /obj/item/weapon/zombie_claw/strong

/datum/species/zombie/strong/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.add_atom_colour(COLOR_DARK_BROWN, FIXED_COLOR_PRIORITY)

/datum/species/zombie/strong/post_species_loss(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.remove_atom_colour(COLOR_DARK_BROWN, FIXED_COLOR_PRIORITY)

/datum/species/zombie/psi_zombie
	name = "Psi zombie" //reanimated by psionic ability
	slowdown = -0.5
	heal_rate = 20
	total_health = 200
	faction = FACTION_SECTOIDS
	hivenumber = FACTION_SECTOIDS
	claw_type = /obj/item/weapon/zombie_claw/no_zombium

/datum/species/zombie/smoker
	name = "Smoker zombie"
	action_list = list(/datum/action/ability/emit_gas)

/particles/smoker_zombie
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list("smoke_1" = 1, "smoke_2" = 1, "smoke_3" = 2)
	width = 100
	height = 100
	count = 5
	spawning = 4
	lifespan = 9
	fade = 10
	grow = 0.2
	velocity = list(0, 0)
	position = generator(GEN_CIRCLE, 10, 10, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(0, -0.15), list(0, 0.15))
	gravity = list(0, 0.4)
	scale = generator(GEN_VECTOR, list(0.3, 0.3), list(0.9,0.9), NORMAL_RAND)
	rotation = 0
	spin = generator(GEN_NUM, 10, 20)

/datum/species/zombie/hunter
	name = "Hunter zombie"
	total_health = 175
	slowdown = 0
	can_jump = TRUE
	claw_type = /obj/item/weapon/zombie_claw/strong
	action_list = list(/datum/action/ability/activable/pounce)

/datum/species/zombie/hunter/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.add_atom_colour(COLOR_ALMOST_BLACK, FIXED_COLOR_PRIORITY)

/datum/species/zombie/hunter/post_species_loss(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.remove_atom_colour(COLOR_ALMOST_BLACK, FIXED_COLOR_PRIORITY)

/datum/species/zombie/boomer
	name = "Boomer zombie"
	heal_rate = 20
	total_health = 250
	action_list = list(
		/datum/action/ability/activable/bile_spit,
		/datum/action/ability/boomer_explode,
	)

/datum/species/zombie/boomer/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.add_atom_colour(COLOR_TOXIN_HUSKPOWDER, FIXED_COLOR_PRIORITY)

/datum/species/zombie/boomer/post_species_loss(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.remove_atom_colour(COLOR_TOXIN_HUSKPOWDER, FIXED_COLOR_PRIORITY)
