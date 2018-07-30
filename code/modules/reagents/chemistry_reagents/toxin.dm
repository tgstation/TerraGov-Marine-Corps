

//////////////////////////Poison stuff///////////////////////

/datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A toxic chemical."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	var/toxpwr = 0.7 // Toxins are really weak, but without being treated, last very long.
	custom_metabolism = 0.1

	on_mob_life(mob/living/M,alien)
		. = ..()
		if(!.) return
		if(alien == IS_YAUTJA) return 0 //immunity to toxin reagents
		if(toxpwr)
			M.adjustToxLoss(toxpwr*REM)
			if(alien) holder.remove_reagent(id, custom_metabolism) //Kind of a catch-all for aliens without kidneys.
			///I don't know what this is supposed to do, since aliens generally have kidneys, but I'm leaving it alone pending rework. /N

/datum/reagent/toxin/hptoxin
	name = "Toxin"
	id = "hptoxin"
	description = "A toxic chemical."
	custom_metabolism = 1
	toxpwr = 1

/datum/reagent/toxin/pttoxin
	name = "Toxin"
	id = "pttoxin"
	description = "A toxic chemical."
	custom_metabolism = 1
	toxpwr = 1

/datum/reagent/toxin/sdtoxin
	name = "Toxin"
	id = "sdtoxin"
	description = "A toxic chemical."
	custom_metabolism = 1
	toxpwr = 0
	on_mob_life(mob/living/M,alien)
		. = ..()
		if(!.) return
		M.adjustOxyLoss(1)


/datum/reagent/toxin/amatoxin
	name = "Amatoxin"
	id = "amatoxin"
	description = "A powerful poison derived from certain species of mushroom."
	reagent_state = LIQUID
	color = "#792300" // rgb: 121, 35, 0
	toxpwr = 1

/datum/reagent/toxin/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94
	toxpwr = 0

	on_mob_life(mob/living/carbon/M)
		. = ..()
		if(!.) return
		if(!istype(M))	return
		M.apply_effect(10,IRRADIATE,0)

/datum/reagent/toxin/phoron
	name = "Phoron"
	id = "phoron"
	description = "Phoron in its liquid form."
	reagent_state = LIQUID
	color = "#E71B00" // rgb: 231, 27, 0
	toxpwr = 3

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		holder.remove_reagent("inaprovaline", 2*REM)

/datum/reagent/toxin/lexorin
	name = "Lexorin"
	id = "lexorin"
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	toxpwr = 0
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		if(M.stat == DEAD)
			return
		if(prob(33))
			M.take_limb_damage(1*REM, 0)
		M.adjustOxyLoss(3)
		if(prob(20)) M.emote("gasp")

	on_overdose(mob/living/M)
		M.apply_damages(2, 0, 2) //Overdose starts getting bad

	on_overdose_critical(mob/living/M)
		M.apply_damages(3, 0, 3) //Overdose starts getting bad

/datum/reagent/toxin/cyanide //Fast and Lethal
	name = "Cyanide"
	id = "cyanide"
	description = "A highly toxic chemical."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 4
	custom_metabolism = 0.4

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.adjustOxyLoss(4*REM)
		M.sleeping += 1

/datum/reagent/toxin/minttoxin
	name = "Mint Toxin"
	id = "minttoxin"
	description = "Useful for dealing with undesirable customers."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 0

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		if(FAT in M.mutations)
			M.gib()

/datum/reagent/toxin/carpotoxin
	name = "Carpotoxin"
	id = "carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded space carp."
	reagent_state = LIQUID
	color = "#003333" // rgb: 0, 51, 51
	toxpwr = 2

/datum/reagent/toxin/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	toxpwr = 0.5

	on_mob_life(mob/living/carbon/M)
		. = ..()
		if(!.) return
		M.status_flags |= FAKEDEATH
		M.adjustOxyLoss(0.5*REM)
		M.KnockDown(10)
		M.silent = max(M.silent, 10)
		M.tod = worldtime2text()

	Dispose()
		if(holder && ismob(holder.my_atom))
			var/mob/M = holder.my_atom
			M.status_flags &= ~FAKEDEATH
		. = ..()

/datum/reagent/toxin/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	description = "A powerful hallucinogen, it can cause fatal effects in users."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 139, 166, 233
	toxpwr = 0
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.hallucination += 10

	on_overdose(mob/living/M, alien)
		if(alien == IS_YAUTJA)  return
		M.apply_damage(1, TOX) //Overdose starts getting bad
		M.make_jittery(5)
		M.knocked_out = max(M.knocked_out, 20)

	on_overdose_critical(mob/living/M, alien)
		if(alien == IS_YAUTJA)  return
		M.apply_damage(4, TOX) //Overdose starts getting bad
		M.make_jittery(10)
		M.knocked_out = max(M.knocked_out, 20)
		M.drowsyness = max(M.drowsyness, 30)

//Reagents used for plant fertilizers.
/datum/reagent/toxin/fertilizer
	name = "fertilizer"
	id = "fertilizer"
	description = "A chemical mix good for growing plants with."
	reagent_state = LIQUID
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
	reagent_state = LIQUID
	color = "#49002E" // rgb: 73, 0, 46
	toxpwr = 1

	reaction_obj(var/obj/O, var/volume)
		if(istype(O,/obj/effect/alien/weeds/))
			var/obj/effect/alien/weeds/alien_weeds = O
			alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
			alien_weeds.healthcheck()
		else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
			cdel(O)
		else if(istype(O,/obj/effect/plantsegment))
			if(prob(50)) cdel(O) //Kills kudzu too.
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

	reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
		src = null
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!C.wear_mask) // If not wearing a mask
				C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.dna)
					if(H.species.flags & IS_PLANT) //plantmen take a LOT of damage
						H.adjustToxLoss(50)

/datum/reagent/toxin/stoxin
	name = "Soporific"
	id = "stoxin"
	description = "An effective hypnotic used to treat insomnia."
	reagent_state = LIQUID
	color = "#E895CC" // rgb: 232, 149, 204
	toxpwr = 0
	custom_metabolism = 0.1
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL
	scannable = 1

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		if(!data) data = 1
		switch(data)
			if(1 to 12)
				if(prob(5))	M.emote("yawn")
			if(12 to 15)
				M.eye_blurry = max(M.eye_blurry, 10)
			if(15 to 49)
				if(prob(50))
					M.KnockDown(2)
				M.drowsyness  = max(M.drowsyness, 20)
			if(50 to INFINITY)
				M.KnockDown(20)
				M.drowsyness  = max(M.drowsyness, 30)
		data++

		M.reagent_pain_modifier += PAIN_REDUCTION_HEAVY

	on_overdose(mob/living/M)
		M.apply_damages(0, 0, 1, 2) //Overdose starts getting bad

	on_overdose_critical(mob/living/M)
		M.apply_damages(0, 0, 2, 3) //Overdose starts getting bad

/datum/reagent/toxin/chloralhydrate
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	description = "A powerful sedative."
	reagent_state = SOLID
	color = "#000067" // rgb: 0, 0, 103
	toxpwr = 1
	custom_metabolism = 0.1 //Default 0.2
	overdose = REAGENTS_OVERDOSE/2
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL/2

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		if(!data) data = 1
		data++
		switch(data)
			if(1)
				M.confused += 2
				M.drowsyness += 2
			if(2 to 199)
				M.KnockDown(30)
			if(200 to INFINITY)
				M.sleeping += 1

	on_overdose(mob/living/M)
		M.apply_damages(0, 0, 2, 3) //Overdose starts getting bad

	on_overdose_critical(mob/living/M)
		M.apply_damages(0, 0, 3, 2) //Overdose starts getting bad

/datum/reagent/toxin/potassium_chloride
	name = "Potassium Chloride"
	id = "potassium_chloride"
	description = "A delicious salt that stops the heart when injected into cardiac muscle."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255
	toxpwr = 0
	overdose = 30

	on_mob_life(mob/living/carbon/M)
		. = ..()
		if(!.) return
		var/mob/living/carbon/human/H = M
		if(H.stat != 1)
			if(volume >= overdose)
				if(H.losebreath >= 10)
					H.losebreath = max(10, H.losebreath-10)
				H.adjustOxyLoss(2)
				H.KnockDown(10)

/datum/reagent/toxin/potassium_chlorophoride
	name = "Potassium Chlorophoride"
	id = "potassium_chlorophoride"
	description = "A specific chemical based on Potassium Chloride to stop the heart for surgery. Not safe to eat!"
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255
	toxpwr = 2
	overdose = 20

	on_mob_life(mob/living/carbon/M)
		. = ..()
		if(!.) return
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.stat != 1)
				if(H.losebreath >= 10)
					H.losebreath = max(10, M.losebreath-10)
				H.adjustOxyLoss(2)
				H.KnockDown(10)

/datum/reagent/toxin/beer2	//disguised as normal beer for use by emagged brobots
	name = "Beer"
	id = "beer2"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water. The fermentation appears to be incomplete." //If the players manage to analyze this, they deserve to know something is wrong.
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	custom_metabolism = 0.15 // Sleep toxins should always be consumed pretty fast
	overdose = REAGENTS_OVERDOSE/2
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL/2

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		if(!data) data = 1
		switch(data)
			if(1)
				M.confused += 2
				M.drowsyness += 2
			if(2 to 50)
				M.sleeping += 1
			if(51 to INFINITY)
				M.sleeping += 1
				M.adjustToxLoss((data - 50)*REM)
		data++

	on_overdose(mob/living/M)
		M.apply_damages(0, 0, 2, 3) //Overdose starts getting bad

	on_overdose_critical(mob/living/M)
		M.apply_damages(0, 0, 3, 2) //Overdose starts getting bad

/datum/reagent/toxin/acid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A very corrosive mineral acid with the molecular formula H2SO4."
	reagent_state = LIQUID
	spray_warning = TRUE
	color = "#DB5008" // rgb: 219, 80, 8
	toxpwr = 1
	var/meltprob = 10

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.take_limb_damage(0, 1*REM)

	reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//magic numbers everywhere
		if(!istype(M, /mob/living))
			return
		if(method == TOUCH)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M

				if(H.head)
					if(prob(meltprob) && !H.head.unacidable)
						H << "<span class='danger'>Your headgear melts away but protects you from the acid!</span>"
						cdel(H.head)
						H.update_inv_head(0)
						H.update_hair(0)
					else
						H << "<span class='warning'>Your headgear protects you from the acid.</span>"
					return

				if(H.wear_mask)
					if(prob(meltprob) && !H.wear_mask.unacidable)
						H << "<span class='danger'>Your mask melts away but protects you from the acid!</span>"
						cdel(H.wear_mask)
						H.update_inv_wear_mask(0)
						H.update_hair(0)
					else
						H << "<span class='warning'>Your mask protects you from the acid.</span>"
					return

				if(H.glasses) //Doesn't protect you from the acid but can melt anyways!
					if(prob(meltprob) && !H.glasses.unacidable)
						H << "<span class='danger'>Your glasses melts away!</span>"
						cdel(H.glasses)
						H.update_inv_glasses(0)

			else if(ismonkey(M))
				var/mob/living/carbon/monkey/MK = M
				if(MK.wear_mask)
					if(!MK.wear_mask.unacidable)
						MK << "<span class='danger'>Your mask melts away but protects you from the acid!</span>"
						cdel(MK.wear_mask)
						MK.update_inv_wear_mask(0)
					else
						MK << "<span class='warning'>Your mask protects you from the acid.</span>"
					return

			if(!M.unacidable)
				if(istype(M, /mob/living/carbon/human) && volume >= 10)
					var/mob/living/carbon/human/H = M
					var/datum/limb/affecting = H.get_limb("head")
					if(affecting)
						if(affecting.take_damage(4*toxpwr, 2*toxpwr))
							H.UpdateDamageIcon()
						if(prob(meltprob)) //Applies disfigurement
							if(!(H.species && (H.species.flags & NO_PAIN)))
								H.emote("scream")
							H.status_flags |= DISFIGURED
							H.name = H.get_visible_name()
				else
					M.take_limb_damage(min(6*toxpwr, volume * toxpwr)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
		else
			if(!M.unacidable)
				M.take_limb_damage(min(6*toxpwr, volume * toxpwr))

	reaction_obj(var/obj/O, var/volume)
		if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(meltprob * 3))
			if(!O.unacidable)
				var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(O.loc)
				I.desc = "Looks like this was \an [O] some time ago."
				for(var/mob/M in viewers(5, O))
					M << "\red \the [O] melts."
				cdel(O)

/datum/reagent/toxin/acid/polyacid
	name = "Polytrinic acid"
	id = "pacid"
	description = "Polytrinic acid is a an extremely corrosive chemical substance."
	reagent_state = LIQUID
	color = "#8E18A9" // rgb: 142, 24, 169
	toxpwr = 2
	meltprob = 30
