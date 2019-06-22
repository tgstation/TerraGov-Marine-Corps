

/datum/reagent/blood
	name = "Blood"
	id = "blood"
	reagent_state = LIQUID
	color = "#A10808"
	taste_description = "iron"
	data = new/list("blood_DNA"=null,"blood_type"=null,"blood_colour"= "#A10808", "trace_chem"=null)


/datum/reagent/blood/reaction_turf(turf/T, volume)//splash the blood all over the place
	if(volume < 3)
		return
	var/list/L = list()
	if(data["blood_DNA"])
		L = list(data["blood_DNA"] = data["blood_type"])
	T.add_blood(L , color)

/datum/reagent/blood/synth_blood
	name = "Synthetic Blood"
	id = "whiteblood"
	color = "#EEEEEE"
	taste_description = "sludge"
	description = "A synthetic blood-like liquid used by all Synthetics."

/datum/reagent/blood/xeno_blood
	name = "Acid Blood"
	id = "xenoblood"
	color = "#dffc00"
	taste_description = "acid"
	description = "A corrosive yellow-ish liquid..."


/datum/reagent/water
	name = "Water"
	id = "water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200
	custom_metabolism = 0.01
	taste_description = "water"

/datum/reagent/water/reaction_turf(turf/T, volume)
	if(volume >= 3)
		T.wet_floor(FLOOR_WET_WATER)

/datum/reagent/water/reaction_obj(obj/O, volume)
	if(istype(O,/obj/item/reagent_container/food/snacks/monkeycube))
		var/obj/item/reagent_container/food/snacks/monkeycube/cube = O
		if(!cube.package)
			cube.Expand()

/datum/reagent/water/reaction_mob(mob/living/L, method = TOUCH, volume, metabolism, show_message = TRUE, touch_protection = 0) //Splashing people with water can help put them out!
	. = ..()
	if(method in list(TOUCH, VAPOR))
		L.adjust_fire_stacks(-(volume / 10))
		if(L.fire_stacks <= 0)
			L.ExtinguishMob()

/datum/reagent/water/holywater
	name = "Holy Water"
	id = "holywater"
	description = "An ashen-obsidian-water mix, this solution will alter certain sections of the brain's rationality."
	color = "#E0E8EF" // rgb: 224, 232, 239

/datum/reagent/lube
	name = "Space Lube"
	id = "lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	reagent_state = LIQUID
	spray_warning = TRUE
	color = "#009CA8" // rgb: 0, 156, 168
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "cherry"

/datum/reagent/lube/reaction_turf(turf/T, volume)
	if(!istype(T))
		return
	if(volume >= 1)
		T.wet_floor(FLOOR_WET_LUBE)

/datum/reagent/lube/overdose_process(mob/living/L, metabolism)
	L.apply_damage(2, TOX)

/datum/reagent/lube/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(3, TOX)

/datum/reagent/space_drugs
	name = "Space drugs"
	id = "space_drugs"
	description = "An illegal chemical compound used as drug."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "bitterness"
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	trait_flags = BRADYCARDICS

/datum/reagent/space_drugs/on_mob_life(mob/living/L, metabolism)
	L.set_drugginess(15)
	if(prob(10) && !L.incapacitated(TRUE) && !L.pulledby && isfloorturf(L.loc))
		step(L, pick(GLOB.cardinals))
	if(prob(7))
		L.emote(pick("twitch","drool","moan","giggle"))
	return ..()

/datum/reagent/space_drugs/overdose_process(mob/living/L, metabolism)
	L.apply_damage(0.5, TOX)
	if(prob(5) && !L.stat)
		L.KnockOut(5)
	L.hallucination += 2

/datum/reagent/space_drugs/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)
	if(prob(10) && !L.stat)
		L.KnockOut(5)
		L.Dizzy(8)

/datum/reagent/serotrotium
	name = "Serotrotium"
	id = "serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	reagent_state = LIQUID
	color = "#202040" // rgb: 20, 20, 40
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "bitterness"

/datum/reagent/serotrotium/on_mob_life(mob/living/L, metabolism)
	if(prob(7))
		L.emote(pick("twitch","drool","moan","gasp","yawn"))
	if(prob(2))
		L.drowsyness += 5
	return ..()

/datum/reagent/serotrotium/overdose_process(mob/living/L, metabolism)
	L.apply_damage(0.3, TOX)
	L.drowsyness = max(L.drowsyness, 5)

/datum/reagent/serotrotium/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(0.7, TOX)
	if(prob(10) && !L.stat)
		L.Sleeping(30)
	L.drowsyness = max(L.drowsyness, 30)

/datum/reagent/oxygen
	name = "Oxygen"
	id = "oxygen"
	description = "A colorless, odorless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_multi = 0

	custom_metabolism = 0.01

/datum/reagent/oxygen/on_mob_life(mob/living/L, metabolism)
	if(metabolism & IS_VOX)
		L.adjustToxLoss(REAGENTS_METABOLISM)
	return ..()

/datum/reagent/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal."
	color = "#6E3B08" // rgb: 110, 59, 8
	taste_description = "metal"

	custom_metabolism = 0.01

/datum/reagent/nitrogen
	name = "Nitrogen"
	id = "nitrogen"
	description = "A colorless, odorless, tasteless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_multi = 0

	custom_metabolism = 0.01

/datum/reagent/nitrogen/on_mob_life(mob/living/L, metabolism)
	if(metabolism & IS_VOX)
		L.adjustOxyLoss(-2*REM)
	return ..()

/datum/reagent/hydrogen
	name = "Hydrogen"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	custom_metabolism = 0.01
	taste_multi = 0

/datum/reagent/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	color = "#A0A0A0" // rgb: 160, 160, 160
	taste_description = "sweetness"

	custom_metabolism = 0.01

/datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A chemical element."
	reagent_state = LIQUID
	color = "#484848" // rgb: 72, 72, 72
	taste_multi = 0

/datum/reagent/mercury/on_mob_life(mob/living/L, metabolism)
	if(!L.incapacitated(TRUE) && !L.pulledby && isfloorturf(L.loc))
		step(L, pick(GLOB.cardinals))
	if(prob(5))
		L.emote(pick("twitch","drool","moan"))
	L.adjustBrainLoss(1, TRUE)
	return ..()

/datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A chemical element with a pungent smell."
	color = "#BF8C00" // rgb: 191, 140, 0
	custom_metabolism = 0.01
	taste_description = "rotten eggs"

/datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A chemical element, the builing block of life."
	color = "#1C1300" // rgb: 30, 20, 0
	custom_metabolism = 0.01
	taste_description = "sour chalk"

/datum/reagent/carbon/reaction_turf(turf/T, volume)
	if(!isspaceturf(T))
		var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, T)
		if(!dirtoverlay)
			dirtoverlay = new/obj/effect/decal/cleanable/dirt(T)
			dirtoverlay.alpha = volume*30
		else
			dirtoverlay.alpha = min(dirtoverlay.alpha+volume*30, 255)

/datum/reagent/chlorine
	name = "Chlorine"
	id = "chlorine"
	description = "A chemical element with a characteristic odour."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "chlorine"

/datum/reagent/chlorine/on_mob_life(mob/living/L, metabolism)
	L.take_limb_damage(REM, 0)
	return ..()

/datum/reagent/chlorine/overdose_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)

/datum/reagent/chlorine/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)

/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A highly-reactive chemical element."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "acid"

/datum/reagent/fluorine/on_mob_life(mob/living/L, metabolism)
	L.adjustToxLoss(REM)
	return ..()

/datum/reagent/fluorine/overdose_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)

/datum/reagent/fluorine/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)

/datum/reagent/sodium
	name = "Sodium"
	id = "sodium"
	description = "A chemical element, readily reacts with water."
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "salty metal"
	custom_metabolism = 0.01

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A chemical element, the backbone of biological energy carriers."
	color = "#832828" // rgb: 131, 40, 40
	custom_metabolism = 0.01
	taste_description = "vinegar"

/datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element, used as antidepressant."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "metal"

/datum/reagent/lithium/on_mob_life(mob/living/L, metabolism)
	if(!L.incapacitated(TRUE) && !L.pulledby && isfloorturf(L.loc))
		step(L, pick(GLOB.cardinals))
	if(prob(5))
		L.emote(pick("twitch","drool","moan"))
	return ..()

/datum/reagent/lithium/overdose_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX) //Overdose starts getting bad

/datum/reagent/lithium/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(2, TOX) //Overdose starts getting bad

/datum/reagent/glycerol
	name = "Glycerol"
	id = "glycerol"
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	reagent_state = LIQUID
	color = "#808080" // rgb: 128, 128, 128
	custom_metabolism = 0.01

/datum/reagent/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
	reagent_state = LIQUID
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01
	trait_flags = TACHYCARDIC

/datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
	taste_description = "the colour blue and regret"

/datum/reagent/radium/on_mob_life(mob/living/L, metabolism)
	L.apply_effect(2*REM/L.metabolism_efficiency,IRRADIATE,0)
	return ..()

/datum/reagent/radium/reaction_turf(turf/T, volume)
	if(volume <= 3 || !isfloorturf(T))
		return
	var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
	if(!glow)
		new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/thermite
	name = "Thermite"
	id = "thermite"
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	color = "#673910" // rgb: 103, 57, 16
	taste_description = "sweet tasting metal"

/datum/reagent/thermite/reaction_turf(turf/T, volume)
	if(volume >= 5 && iswallturf(T))
		var/turf/closed/wall/W = T
		W.thermite = TRUE
		W.add_overlay(image('icons/effects/effects.dmi',icon_state = "#673910"))

/datum/reagent/thermite/on_mob_life(mob/living/L, metabolism)
	L.adjustFireLoss(1)
	return ..()

/datum/reagent/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "iron"

/datum/reagent/iron/on_mob_life(mob/living/L, metabolism)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.blood_volume < BLOOD_VOLUME_NORMAL)
			C.blood_volume += 0.8
	return ..()

/datum/reagent/iron/overdose_process(mob/living/L, metabolism)
	L.apply_damages(1, 0, 1)

/datum/reagent/iron/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(1, 0, 1)

/datum/reagent/gold
	name = "Gold"
	id = "gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	color = "#F7C430" // rgb: 247, 196, 48
	taste_description = "expensive metal"

/datum/reagent/silver
	name = "Silver"
	id = "silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	color = "#D0D0D0" // rgb: 208, 208, 208
	taste_description = "expensive yet reasonable metal"

/datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	color = "#B8B8C0" // rgb: 184, 184, 192
	taste_description = "the inside of a reactor"

/datum/reagent/uranium/on_mob_life(mob/living/L, metabolism)
	L.apply_effect(1/L.metabolism_efficiency,IRRADIATE,0)
	return ..()

/datum/reagent/uranium/reaction_turf(turf/T, reac_volume)
	if(reac_volume <= 3 || !isfloorturf(T))
		return
	var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
	if(!glow)
		new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/aluminum
	name = "Aluminum"
	id = "aluminum"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_description = "metal"

/datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_multi = 0

/datum/reagent/fuel
	name = "Welding fuel"
	id = "fuel"
	description = "Required for blowtorches. Highly flamable."
	color = "#660000" // rgb: 102, 0, 0
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "gross metal"

/datum/reagent/fuel/reaction_turf(turf/T, volume)
	if(volume <= 3 || !isfloorturf(T))
		return
	new /obj/effect/decal/cleanable/liquid_fuel(T, volume) //It already handles dupes on it own turf.

/datum/reagent/fuel/on_mob_life(mob/living/L)
	L.adjustToxLoss(1)
	return ..()

/datum/reagent/fuel/reaction_mob(mob/living/L, method = TOUCH, volume, metabolism, show_message = TRUE, touch_protection = 0)//Splashing people with welding fuel to make them easy to ignite!
	. = ..()
	if(method in list(TOUCH, VAPOR))
		L.adjust_fire_stacks(volume / 10)
	return TRUE

/datum/reagent/fuel/overdose_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)

/datum/reagent/fuel/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)

/datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	reagent_state = LIQUID
	color = "#A5F0EE" // rgb: 165, 240, 238
	taste_description = "sourness"
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL

/datum/reagent/space_cleaner/reaction_obj(obj/O, volume)
	if(istype(O,/obj/effect/decal/cleanable))
		qdel(O)
	else if(O)
		O.clean_blood()

/datum/reagent/space_cleaner/reaction_turf(turf/T, volume)
	if(volume >= 1)
		T.clean_blood()
		for(var/obj/effect/decal/cleanable/C in T.contents)
			reaction_obj(C, volume)
			qdel(C)

/datum/reagent/space_cleaner/reaction_mob(mob/living/L, method = TOUCH, volume, metabolism, show_message = TRUE, touch_protection = 0)
	. = ..()
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.r_hand)
			C.r_hand.clean_blood()
		if(C.l_hand)
			C.l_hand.clean_blood()
		if(C.wear_mask)
			if(C.wear_mask.clean_blood())
				C.update_inv_wear_mask(0)
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.head)
				if(H.head.clean_blood())
					H.update_inv_head(0)
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0)
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0)
			if(H.shoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes(0)
			else
				H.clean_blood(1)
			return
	L.clean_blood()

/datum/reagent/space_cleaner/overdose_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)

/datum/reagent/space_cleaner/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	description = "Cryptobiolin causes confusion and dizzyness."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	taste_description = "sourness"
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL

/datum/reagent/cryptobiolin/on_mob_life(mob/living/L, metabolism)
	L.Dizzy(2)
	L.confused = max(L.confused, 20)
	return ..()

/datum/reagent/cryptobiolin/overdose_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)

/datum/reagent/cryptobiolin/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX)

/datum/reagent/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	taste_description = "numbness"
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL

/datum/reagent/impedrezene/on_mob_life(mob/living/L, metabolism)
	L.Jitter(-5)
	if(prob(80))
		L.adjustBrainLoss(2*REM, TRUE)
	if(prob(50))
		L.drowsyness = max(L.drowsyness, 3)
	if(prob(10))
		L.emote("drool")
	return ..()

/datum/reagent/impedrezene/overdose_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX) //Overdose starts getting bad

/datum/reagent/impedrezene/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damage(1, TOX) //Overdose starts getting bad


///////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/nanites
	name = "Nanomachines"
	id = "nanites"
	description = "Microscopic construction robots."
	taste_description = "sludge"
	reagent_state = LIQUID
	color = "#535E66" // rgb: 83, 94, 102

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	reagent_state = LIQUID
	color = "#535E66" // rgb: 83, 94, 102
	taste_description = "sludge"

/datum/reagent/fluorosurfactant//foam precursor
	name = "Fluorosurfactant"
	id = "fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	reagent_state = LIQUID
	color = "#9E6B38" // rgb: 158, 107, 56
	taste_description = "metal"

/datum/reagent/foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
	name = "Foaming agent"
	id = "foaming_agent"
	description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
	color = "#664B63" // rgb: 102, 75, 99
	taste_description = "metal"

/datum/reagent/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "A highly addictive stimulant extracted from the tobacco plant."
	reagent_state = LIQUID
	color = "#181818" // rgb: 24, 24, 24
	taste_description = "smoke"
	trait_flags = TACHYCARDIC

/datum/reagent/ammonia
	name = "Ammonia"
	id = "ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
	taste_description = "mordant"

/datum/reagent/ultraglue
	name = "Ultra Glue"
	id = "glue"
	description = "An extremely powerful bonding agent."
	color = "#FFFFCC" // rgb: 255, 255, 204
	taste_description = "something chewy"

/datum/reagent/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	description = "A secondary amine, mildly corrosive."
	reagent_state = LIQUID
	color = "#604030" // rgb: 96, 64, 48
	taste_description = "iron"

/datum/reagent/lipozine
	name = "Lipozine" // The anti-nutriment.
	id = "lipozine"
	description = "A chemical compound that causes a powerful fat-burning reaction."
	reagent_state = LIQUID
	color = "#BBEDA4" // rgb: 187, 237, 164
	overdose_threshold = REAGENTS_OVERDOSE
	overdose_crit_threshold = REAGENTS_OVERDOSE_CRITICAL
	taste_description = "bitterness"

/datum/reagent/lipozine/on_mob_life(mob/living/L, metabolism)
	if(!iscarbon(L))
		return ..()
	var/mob/living/carbon/C = L
	if(C.nutrition > 50)
		C.overeatduration = 0
		C.nutrition -= 10
	if(prob(20))
		C.adjustToxLoss(0.1)
	else
		C.adjustToxLoss(1)
	return ..()

/datum/reagent/consumable/lipozine/overdose_process(mob/living/L, metabolism)
	L.apply_damages(0, 1, 1)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.nutrition > 100)
			C.nutrition -= 10

/datum/reagent/consumable/lipozine/overdose_crit_process(mob/living/L, metabolism)
	L.apply_damages(1, 3, 1)

/datum/reagent/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	color = "#C8A5DC" // rgb: 200, 165, 220


/datum/reagent/sterilizine/reaction_mob(mob/living/L, method = TOUCH, volume, metabolism, show_message = TRUE, touch_protection = 0)
	if(!(method in list(TOUCH, VAPOR, PATCH)))
		return
	L.germ_level -= min(volume * 20 * touch_protection, L.germ_level)
	if((L.getFireLoss() > 30 || L.getBruteLoss() > 30) && prob(10)) // >Spraying space bleach on open wounds
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			if(C.species.species_flags & NO_PAIN)
				return
		if(show_message)
			to_chat(L, "<span class='warning'>Your open wounds feel like they're on fire!</span>")
		L.emote(pick("scream","pain","moan"))
		L.flash_pain()
		L.reagent_shock_modifier -= PAIN_REDUCTION_MEDIUM

/datum/reagent/sterilizine/reaction_obj(obj/O, volume)
	O.germ_level -= min(volume*20, O.germ_level)

/datum/reagent/medicine/sterilizine/reaction_turf(turf/T, volume)
	T.germ_level -= min(volume*20, T.germ_level)

/datum/reagent/sterilizine/on_mob_life(mob/living/L, metabolism)
	L.adjustToxLoss(2*REM)
	return ..()
