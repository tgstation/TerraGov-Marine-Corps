

//////////////////////////Poison stuff///////////////////////

/datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A toxic chemical."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	var/toxpwr = 0.7 // Toxins are really weak, but without being treated, last very long.
	custom_metabolism = 0.1
	taste_description = "bitterness"
	taste_multi = 1.2

/datum/reagent/toxin/on_mob_life(mob/living/carbon/M , alien)
	var/mob/living/carbon/human/H = M
	if(H.species.species_flags & NO_POISON)
		return FALSE //immunity to toxin reagents
	if(toxpwr)
		M.adjustToxLoss(toxpwr*REM)
	..()

/datum/reagent/toxin/hptoxin
	name = "Toxin"
	id = "hptoxin"
	description = "A toxic chemical."
	custom_metabolism = 1
	toxpwr = 1
	taste_description = "alchemy" //just anti-pwr-game stuff, no sci-fi or anything

/datum/reagent/toxin/pttoxin
	name = "Toxin"
	id = "pttoxin"
	description = "A toxic chemical."
	custom_metabolism = 1
	toxpwr = 1
	taste_description = "alchemy"

/datum/reagent/toxin/sdtoxin
	name = "Toxin"
	id = "sdtoxin"
	description = "A toxic chemical."
	custom_metabolism = 1
	toxpwr = 0
	taste_description = "alchemy"

/datum/reagent/toxin/sdtoxin/on_mob_life(mob/living/carbon/M,alien)
	M.adjustOxyLoss(1)
	..()


/datum/reagent/toxin/amatoxin
	name = "Amatoxin"
	id = "amatoxin"
	description = "A powerful poison derived from certain species of mushroom."
	color = "#792300" // rgb: 121, 35, 0
	toxpwr = 1
	taste_description = "mushrooms"

/datum/reagent/toxin/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	color = "#13BC5E" // rgb: 19, 188, 94
	toxpwr = 0
	taste_description = "slime"
	taste_multi = 0.9

/datum/reagent/toxin/mutagen/on_mob_life(mob/living/carbon/M)
	M.apply_effect(10,IRRADIATE,0)
	..()

/datum/reagent/toxin/phoron
	name = "Phoron"
	id = "phoron"
	description = "Phoron in its liquid form."
	color = "#E71B00" // rgb: 231, 27, 0
	toxpwr = 3

/datum/reagent/toxin/phoron/on_mob_life(mob/living/carbon/M)
	holder.remove_reagent("inaprovaline", 2*REM)
	..()

/datum/reagent/toxin/lexorin
	name = "Lexorin"
	id = "lexorin"
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	color = "#C8A5DC" // rgb: 200, 165, 220
	toxpwr = 0
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "acid"

/datum/reagent/toxin/lexorin/on_mob_life(mob/living/carbon/M)
	if(prob(33))
		M.take_limb_damage(1*REM, 0)
	M.adjustOxyLoss(3)
	if(prob(20))
		M.emote("gasp")
	..()

/datum/reagent/toxin/lexorin/overdose_process(mob/living/carbon/M)
	M.apply_damages(0, 1, 1) //Overdose starts getting bad

/datum/reagent/toxin/lexorin/overdose_crit_process(mob/living/carbon/M)
	M.apply_damages(1, 0, 1) //Overdose starts getting bad

/datum/reagent/toxin/cyanide //Fast and Lethal
	name = "Cyanide"
	id = "cyanide"
	description = "A highly toxic chemical."
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 3
	custom_metabolism = 0.4

/datum/reagent/toxin/cyanide/on_mob_life(mob/living/M)
	M.adjustOxyLoss(4*REM)
	if(current_cycle > 10)
		M.Sleeping(2)
	..()

/datum/reagent/toxin/minttoxin
	name = "Mint Toxin"
	id = "minttoxin"
	description = "Useful for dealing with undesirable customers."
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 0
	taste_description = "mint"

/datum/reagent/toxin/minttoxin/on_mob_life(mob/living/M)
	if(FAT in M.mutations)
		M.gib()
	..()

/datum/reagent/toxin/carpotoxin
	name = "Carpotoxin"
	id = "carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded space carp."
	color = "#003333" // rgb: 0, 51, 51
	toxpwr = 2
	taste_description = "fish"

/datum/reagent/toxin/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	toxpwr = 0.5
	taste_description = "death"

/datum/reagent/toxin/zombiepowder/on_mob_add(mob/living/carbon/M)
	..()
	M.status_flags |= FAKEDEATH

/datum/reagent/toxin/zombiepowder/on_mob_life(mob/living/carbon/M)
	M.adjustOxyLoss(0.5*REM)
	M.KnockDown(10)
	M.silent = max(M.silent, 10)
	..()

/datum/reagent/toxin/zombiepowder/on_mob_delete(mob/living/M)
	M.status_flags &= ~FAKEDEATH
	..()

/datum/reagent/toxin/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	description = "A powerful hallucinogen, it can cause fatal effects in users."
	color = "#B31008" // rgb: 139, 166, 233
	toxpwr = 0
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "sourness"

/datum/reagent/toxin/mindbreaker/on_mob_life(mob/living/M)
	M.hallucination += 10
	..()

/datum/reagent/toxin/mindbreaker/overdose_process(mob/living/M, alien)
	M.adjustToxLoss(1)
	M.Jitter(5)
	if(prob(10) && !M.stat)
		M.KnockOut(5)

/datum/reagent/toxin/mindbreaker/overdose_crit_process(mob/living/M, alien)
	M.adjustToxLoss(1)
	M.adjustBrainLoss(1, TRUE)
	M.Jitter(5)
	if(prob(10) && !M.stat)
		M.KnockOut(5)
	M.drowsyness = max(M.drowsyness, 30)

//Reagents used for plant fertilizers.
/datum/reagent/toxin/fertilizer
	name = "fertilizer"
	id = "fertilizer"
	description = "A chemical mix good for growing plants with."
	toxpwr = 0.2 //It's not THAT poisonous.
	color = "#664330" // rgb: 102, 67, 48

/datum/reagent/toxin/fertilizer/eznutrient
	name = "EZ Nutrient"
	id = "eznutrient"

/datum/reagent/toxin/fertilizer/left4zed
	name = "Left-4-Zed"
	id = "left4zed"

/datum/reagent/toxin/fertilizer/robustharvest
	name = "Robust Harvest"
	id = "robustharvest"

/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
	color = "#49002E" // rgb: 73, 0, 46
	toxpwr = 1
	taste_multi = 1

/datum/reagent/toxin/plantbgone/reaction_obj(obj/O, volume)
	if(istype(O,/obj/effect/alien/weeds/))
		var/obj/effect/alien/weeds/alien_weeds = O
		alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
		alien_weeds.healthcheck()
	else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/effect/plantsegment))
		if(prob(50)) qdel(O) //Kills kudzu too.
	else if(istype(O,/obj/machinery/portable_atmospherics/hydroponics))
		var/obj/machinery/portable_atmospherics/hydroponics/tray = O

		if(tray.seed)
			tray.health -= rand(30,50)
			if(tray.pestlevel > 0)
				tray.pestlevel -= 2
			if(tray.weedlevel > 0)
				tray.weedlevel -= 3
			tray.toxins += 4
			tray.check_level_sanity()
			tray.update_icon()

/datum/reagent/toxin/plantbgone/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.dna)
				if(H.species.species_flags & IS_PLANT) //plantmen take a LOT of damage
					H.adjustToxLoss(10)

/datum/reagent/toxin/sleeptoxin
	name = "Soporific"
	id = "sleeptoxin"
	description = "An effective hypnotic used to treat insomnia."
	color = "#E895CC" // rgb: 232, 149, 204
	toxpwr = 0
	custom_metabolism = 0.1
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	scannable = 1
	taste_description = "cough syrup"

/datum/reagent/toxin/sleeptoxin/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 12)
			if(prob(5))
				M.emote("yawn")
		if(13 to 15)
			M.blur_eyes(10)
		if(16 to 40)
			if(prob(10))
				M.Sleeping(10)
			M.drowsyness  = max(M.drowsyness, 20)
		if(41 to INFINITY)
			M.Sleeping(20) //previously knockdown, no good for a soporific.
			M.drowsyness  = max(M.drowsyness, 30)
	M.reagent_pain_modifier += PAIN_REDUCTION_HEAVY
	..()

/datum/reagent/toxin/sleeptoxin/overdose_process(mob/living/M, alien)
	M.apply_damages(0, 0, 1, 2) //Overdose starts getting bad

/datum/reagent/toxin/sleeptoxin/overdose_crit_process(mob/living/M)
	M.apply_damages(0, 0, 1, 1) //Overdose starts getting bad

/datum/reagent/toxin/chloralhydrate
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	description = "A powerful sedative."
	reagent_state = SOLID
	color = "#000067" // rgb: 0, 0, 103
	toxpwr = 0
	custom_metabolism = 0.1 //Default 0.2
	overdose_threshold = REAGENTS_OVERDOSE/2
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL/2

/datum/reagent/toxin/chloralhydrate/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 20)
			M.confused += 2
			M.drowsyness += 2
		if(21 to 60)
			M.Sleeping(5)
		if(61 to INFINITY)
			M.Sleeping(5)
			M.adjustToxLoss((current_cycle/2 - 50)*REM)
	..()

/datum/reagent/toxin/chloralhydrate/overdose_process(mob/living/M, alien)
	M.apply_damages(0, 0, 1, 2) //Overdose starts getting bad

/datum/reagent/toxin/chloralhydrate/overdose_crit_process(mob/living/M)
	M.apply_damages(0, 0, 0, 2) //Overdose starts getting bad

/datum/reagent/toxin/potassium_chloride
	name = "Potassium Chloride"
	id = "potassium_chloride"
	description = "A delicious salt that stops the heart when injected into cardiac muscle."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255
	toxpwr = 0
	overdose_threshold = REAGENTS_OVERDOSE

/datum/reagent/toxin/potassium_chloride/overdose_process(mob/living/carbon/M, alien)
	if(M.losebreath > 10)
		M.set_Losebreath(10)
	M.adjustOxyLoss(2)
	switch(current_cycle)
		if(7 to 15)
			M.KnockDown(5)
		if(16 to INFINITY)
			M.KnockOut(5)
	..()

/datum/reagent/toxin/potassium_chlorophoride
	name = "Potassium Chlorophoride"
	id = "potassium_chlorophoride"
	description = "A specific chemical based on Potassium Chloride to stop the heart for surgery. Not safe to eat!"
	color = "#FFFFFF" // rgb: 255,255,255
	toxpwr = 2

/datum/reagent/toxin/potassium_chlorophoride/on_mob_life(mob/living/carbon/M)
	if(M.stat != UNCONSCIOUS)
		if(M.losebreath > 10)
			M.set_Losebreath(10)
		M.adjustOxyLoss(2)
	switch(current_cycle)
		if(7 to 15)
			M.KnockDown(5)
		if(16 to INFINITY)
			M.KnockOut(5)
	..()

/datum/reagent/toxin/beer2	//disguised as normal beer for use by emagged brobots
	name = "Beer"
	id = "beer2"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water. The fermentation appears to be incomplete." //If the players manage to analyze this, they deserve to know something is wrong.
	color = "#664300" // rgb: 102, 67, 0
	custom_metabolism = 0.5 // Sleep toxins should always be consumed pretty fast
	taste_description = "piss water"

/datum/reagent/toxin/beer2/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 50)
			M.Sleeping(5)
		if(51 to INFINITY)
			M.Sleeping(5)
			M.adjustToxLoss((current_cycle - 50)*REM)
	..()

/datum/reagent/toxin/acid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A very corrosive mineral acid with the molecular formula H2SO4."
	spray_warning = TRUE
	color = "#DB5008" // rgb: 219, 80, 8
	toxpwr = 1
	var/meltprob = 10
	taste_description = "acid"

/datum/reagent/toxin/acid/on_mob_life(mob/living/M)
	M.take_limb_damage(0, 1*REM)
	..()

/datum/reagent/toxin/acid/reaction_mob(mob/living/M, method=TOUCH, volume)//magic numbers everywhere
	if(method == TOUCH || method == VAPOR)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.head)
				if(prob(meltprob) && !CHECK_BITFIELD(H.head.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
					to_chat(H, "<span class='danger'>Your headgear melts away but protects you from the acid!</span>")
					qdel(H.head)
					H.update_inv_head(0)
					H.update_hair(0)
				else
					to_chat(H, "<span class='warning'>Your headgear protects you from the acid.</span>")
				return

			if(H.wear_mask)
				if(prob(meltprob) && !CHECK_BITFIELD(H.wear_mask.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
					to_chat(H, "<span class='danger'>Your mask melts away but protects you from the acid!</span>")
					qdel(H.wear_mask)
					H.update_inv_wear_mask(0)
					H.update_hair(0)
				else
					to_chat(H, "<span class='warning'>Your mask protects you from the acid.</span>")
				return

			if(H.glasses) //Doesn't protect you from the acid but can melt anyways!
				if(prob(meltprob) && !CHECK_BITFIELD(H.glasses.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
					to_chat(H, "<span class='danger'>Your glasses melts away!</span>")
					qdel(H.glasses)
					H.update_inv_glasses(0)

		else if(ismonkey(M))
			var/mob/living/carbon/monkey/MK = M
			if(MK.wear_mask)
				if(!CHECK_BITFIELD(MK.wear_mask.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
					to_chat(MK, "<span class='danger'>Your mask melts away but protects you from the acid!</span>")
					qdel(MK.wear_mask)
					MK.update_inv_wear_mask(0)
				else
					to_chat(MK, "<span class='warning'>Your mask protects you from the acid.</span>")
				return

		if(!M.unacidable)
			if(ishuman(M) && volume >= 10)
				var/mob/living/carbon/human/H = M
				var/datum/limb/affecting = H.get_limb("head")
				if(affecting)
					if(affecting.take_damage_limb(4 * toxpwr, 2 * toxpwr))
						H.UpdateDamageIcon()
					if(prob(meltprob)) //Applies disfigurement
						if(!(H.species && (H.species.species_flags & NO_PAIN)))
							H.emote("scream")
						H.status_flags |= DISFIGURED
						H.name = H.get_visible_name()
			else
				M.take_limb_damage(min(6*toxpwr, volume * toxpwr)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
	else
		if(!M.unacidable)
			M.take_limb_damage(min(6*toxpwr, volume * toxpwr))

/datum/reagent/toxin/acid/reaction_obj(var/obj/O, var/volume)
	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(meltprob * 3))
		if(!CHECK_BITFIELD(O.resistance_flags, UNACIDABLE|INDESTRUCTIBLE))
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
			I.desc = "Looks like this was \an [O] some time ago."
			for(var/mob/M in viewers(5, O))
				to_chat(M, "<span class='warning'>\the [O] melts.</span>")
				qdel(O)

/datum/reagent/toxin/acid/polyacid
	name = "Polytrinic acid"
	id = "pacid"
	description = "Polytrinic acid is a an extremely corrosive chemical substance."
	color = "#8E18A9" // rgb: 142, 24, 169
	toxpwr = 2
	meltprob = 30
	taste_multi = 1.5
