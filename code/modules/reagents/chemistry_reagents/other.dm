

/datum/reagent/blood
	name = "Blood"
	id = "blood"
	reagent_state = LIQUID
	color = "#A10808"
	data = new/list("blood_DNA"=null,"blood_type"=null,"blood_colour"= "#A10808","viruses"=null,"resistances"=null, "trace_chem"=null)


/datum/reagent/blood/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	var/datum/reagent/blood/self = src
	src = null
	if(self.data && self.data["viruses"])
		for(var/datum/disease/D in self.data["viruses"])
			//var/datum/disease/virus = new D.type(0, D, 1)
			// We don't spread.
			if(D.spread_type == SPECIAL || D.spread_type == NON_CONTAGIOUS) continue

			if(method == TOUCH)
				M.contract_disease(D)
			else //injected
				M.contract_disease(D, 1, 0)


/datum/reagent/blood/reaction_turf(var/turf/T, var/volume)//splash the blood all over the place
	if(!istype(T)) return
	var/datum/reagent/blood/self = src
	src = null
	if(!(volume >= 3)) return

	var/list/L = list()
	if(self.data["blood_DNA"])
		L = list(self.data["blood_DNA"] = self.data["blood_type"])

	T.add_blood(L , self.color)



/datum/reagent/blood/yaut_blood
	name = "Green Blood"
	id = "greenblood"
	description = "A thick green blood, definitely not human."
	color = "#20d450"

/datum/reagent/blood/synth_blood
	name = "Synthetic Blood"
	id = "whiteblood"
	color = "#EEEEEE"
	description = "A synthetic blood-like liquid used by all Synthetics."

/datum/reagent/blood/zomb_blood
	name = "Grey Blood"
	id = "greyblood"
	color = "#333333"
	description = "A greyish liquid with the same consistency as blood."

/datum/reagent/blood/xeno_blood
	name = "Acid Blood"
	id = "xenoblood"
	color = "#dffc00"
	description = "A corrosive yellow-ish liquid..."



/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	id = "vaccine"
	reagent_state = LIQUID
	color = "#C81040" // rgb: 200, 16, 64

	reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
		if(has_species(M,"Horror")) return
		var/datum/reagent/vaccine/self = src
		src = null
		if(self.data&&method == INGEST)
			for(var/datum/disease/D in M.viruses)
				if(istype(D, /datum/disease/advance))
					var/datum/disease/advance/A = D
					if(A.GetDiseaseID() == self.data)
						D.cure()
				else
					if(D.type == self.data)
						D.cure()

			M.resistances += self.data
		return


/datum/reagent/water
	name = "Water"
	id = "water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200
	custom_metabolism = 0.01

	reaction_turf(var/turf/T, var/volume)
		if(!istype(T)) return
		src = null
		if(volume >= 3)
			T.wet_floor(FLOOR_WET_WATER)

	reaction_obj(var/obj/O, var/volume)
		src = null
		if(istype(O,/obj/item/reagent_container/food/snacks/monkeycube))
			var/obj/item/reagent_container/food/snacks/monkeycube/cube = O
			if(!cube.package)
				cube.Expand()

	reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with water can help put them out!
		if(!istype(M, /mob/living))
			return
		return
		if(method == TOUCH)
			M.adjust_fire_stacks(-(volume / 10))
			if(M.fire_stacks <= 0)
				M.ExtinguishMob()
			return

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
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	reaction_turf(var/turf/T, var/volume)
		if(!istype(T)) return
		src = null
		if(volume >= 1)
			T.wet_floor(FLOOR_WET_LUBE)

	on_overdose(mob/living/M)
		M.apply_damage(2, TOX)

	on_overdose_critical(mob/living/M)
		M.apply_damage(3, TOX)

/datum/reagent/plasticide
	name = "Plasticide"
	id = "plasticide"
	description = "Liquid plastic, do not eat."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	custom_metabolism = 0.01

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		// Toxins are really weak, but without being treated, last very long.
		M.adjustToxLoss(0.2)

/datum/reagent/space_drugs
	name = "Space drugs"
	id = "space_drugs"
	description = "An illegal chemical compound used as drug."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.druggy = max(M.druggy, 15)
		if(isturf(M.loc) && !istype(M.loc, /turf/open/space))
			if(M.canmove && !M.is_mob_restrained())
				if(prob(10)) step(M, pick(cardinal))
		if(prob(7)) M.emote(pick("twitch","drool","moan","giggle"))
		holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)

	on_overdose(mob/living/M)
		M.apply_damage(1, TOX) //Overdose starts getting bad
		M.knocked_out = max(M.knocked_out, 20)

	on_overdose_critical(mob/living/M)
		M.apply_damage(4, TOX) //Overdose starts getting bad
		M.knocked_out = max(M.knocked_out, 20)
		M.drowsyness = max(M.drowsyness, 30)

/datum/reagent/serotrotium
	name = "Serotrotium"
	id = "serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	reagent_state = LIQUID
	color = "#202040" // rgb: 20, 20, 40
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		if(ishuman(M))
			if(prob(7)) M.emote(pick("twitch","drool","moan","gasp"))
			holder.remove_reagent(src.id, 0.25 * REAGENTS_METABOLISM)

	on_overdose(mob/living/M)
		M.apply_damage(1, TOX) //Overdose starts getting bad
		M.knocked_out = max(M.knocked_out, 20)

	on_overdose_critical(mob/living/M)
		M.apply_damage(4, TOX) //Overdose starts getting bad
		M.knocked_out = max(M.knocked_out, 20)
		M.drowsyness = max(M.drowsyness, 30)

/datum/reagent/oxygen
	name = "Oxygen"
	id = "oxygen"
	description = "A colorless, odorless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

	on_mob_life(mob/living/M, alien)
		. = ..()
		if(!.) return
		if(M.stat == 2) return
		if(alien && alien == IS_VOX)
			M.adjustToxLoss(REAGENTS_METABOLISM)
			holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.

/datum/reagent/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal."
	color = "#6E3B08" // rgb: 110, 59, 8

	custom_metabolism = 0.01

/datum/reagent/nitrogen
	name = "Nitrogen"
	id = "nitrogen"
	description = "A colorless, odorless, tasteless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

	on_mob_life(mob/living/M, alien)
		. = ..()
		if(!.) return
		if(M.stat == 2) return
		if(alien && alien == IS_VOX)
			M.adjustOxyLoss(-2*REM)
			holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.

/datum/reagent/hydrogen
	name = "Hydrogen"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

/datum/reagent/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160

	custom_metabolism = 0.01

/datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A chemical element."
	reagent_state = LIQUID
	color = "#484848" // rgb: 72, 72, 72
	overdose = REAGENTS_OVERDOSE

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		if(M.canmove && !M.is_mob_restrained() && istype(M.loc, /turf/open/space))
			step(M, pick(cardinal))
		if(prob(5)) M.emote(pick("twitch","drool","moan"))
		M.adjustBrainLoss(2)

/datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A chemical element with a pungent smell."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0

	custom_metabolism = 0.01

/datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A chemical element, the builing block of life."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0

	custom_metabolism = 0.01

	reaction_turf(var/turf/T, var/volume)
		src = null
		if(!istype(T, /turf/open/space))
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
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.take_limb_damage(REM, 0)

	on_overdose(mob/living/M)
		M.apply_damage(1, TOX) //Overdose starts getting bad

	on_overdose_critical(mob/living/M)
		M.apply_damage(4, TOX) //Overdose starts getting bad

/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A highly-reactive chemical element."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.adjustToxLoss(REM)

	on_overdose(mob/living/M)
		M.apply_damage(1, TOX) //Overdose starts getting bad

	on_overdose_critical(mob/living/M)
		M.apply_damage(4, TOX) //Overdose starts getting bad

/datum/reagent/sodium
	name = "Sodium"
	id = "sodium"
	description = "A chemical element, readily reacts with water."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128

	custom_metabolism = 0.01

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A chemical element, the backbone of biological energy carriers."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40

	custom_metabolism = 0.01

/datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element, used as antidepressant."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		if(M.canmove && !M.is_mob_restrained() && istype(M.loc, /turf/open/space))
			step(M, pick(cardinal))
		if(prob(5)) M.emote(pick("twitch","drool","moan"))

	on_overdose(mob/living/M)
		M.apply_damage(1, TOX) //Overdose starts getting bad

	on_overdose_critical(mob/living/M)
		M.apply_damage(4, TOX) //Overdose starts getting bad

/datum/reagent/sugar
	name = "Sugar"
	id = "sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.nutrition += 1*REM


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

/datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.apply_effect(2*REM,IRRADIATE,0)

	reaction_turf(var/turf/T, var/volume)
		src = null
		if(volume >= 3)
			if(!istype(T, /turf/open/space))
				var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
				if(!glow)
					new /obj/effect/decal/cleanable/greenglow(T)
				return

/datum/reagent/thermite
	name = "Thermite"
	id = "thermite"
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16

	reaction_turf(var/turf/T, var/volume)
		src = null
		if(volume >= 5)
			if(istype(T, /turf/closed/wall))
				var/turf/closed/wall/W = T
				W.thermite = TRUE
				W.overlays += image('icons/effects/effects.dmi',icon_state = "#673910")
		return

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.adjustFireLoss(1)

/datum/reagent/virus_food
	name = "Virus Food"
	id = "virusfood"
	description = "A mixture of water, milk, and oxygen. Virus cells can use this mixture to reproduce."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19

/datum/reagent/virus_food/on_mob_life(mob/living/M)
	. = ..()
	if(!.) return
	M.nutrition += nutriment_factor*REM


/datum/reagent/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

/datum/reagent/iron/on_overdose(mob/living/M)
	M.apply_damages(1, 0, 1) //Overdose starts getting bad

/datum/reagent/iron/on_overdose_critical(mob/living/M)
	M.apply_damages(2, 0, 2) //Overdose starts getting bad

/datum/reagent/iron/on_mob_life(mob/living/M)
	. = ..()
	if(!.) return
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.blood_volume < BLOOD_VOLUME_NORMAL)
			C.blood_volume += 0.8


/datum/reagent/gold
	name = "Gold"
	id = "gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48

/datum/reagent/silver
	name = "Silver"
	id = "silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208

/datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.apply_effect(1,IRRADIATE,0)

	reaction_turf(var/turf/T, var/volume)
		src = null
		if(volume >= 3)
			if(!istype(T, /turf/open/space))
				var/obj/effect/decal/cleanable/greenglow/glow = locate(/obj/effect/decal/cleanable/greenglow, T)
				if(!glow)
					new /obj/effect/decal/cleanable/greenglow(T)

/datum/reagent/aluminum
	name = "Aluminum"
	id = "aluminum"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168

/datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168

/datum/reagent/fuel
	name = "Welding fuel"
	id = "fuel"
	description = "Required for blowtorches. Highly flamable."
	reagent_state = LIQUID
	color = "#660000" // rgb: 102, 0, 0
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	reaction_obj(var/obj/O, var/volume)
		var/turf/the_turf = get_turf(O)
		if(!the_turf)
			return //No sense trying to start a fire if you don't have a turf to set on fire. --NEO
		new /obj/effect/decal/cleanable/liquid_fuel(the_turf, volume)

	reaction_turf(var/turf/T, var/volume)
		new /obj/effect/decal/cleanable/liquid_fuel(T, volume)

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.adjustToxLoss(1)

	reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with welding fuel to make them easy to ignite!
		if(!istype(M, /mob/living))
			return
		if(method == TOUCH)
			M.adjust_fire_stacks(volume / 10)

	on_overdose(mob/living/M)
		M.apply_damage(2, TOX) //Overdose starts getting bad

	on_overdose_critical(mob/living/M)
		M.apply_damage(3, TOX) //Overdose starts getting bad

/datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	reagent_state = LIQUID
	color = "#A5F0EE" // rgb: 165, 240, 238
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	reaction_obj(var/obj/O, var/volume)
		if(istype(O,/obj/effect/decal/cleanable))
			cdel(O)
		else
			if(O)
				O.clean_blood()

	reaction_turf(var/turf/T, var/volume)
		if(volume >= 1)
			T.clean_blood()
			for(var/obj/effect/decal/cleanable/C in T.contents)
				src.reaction_obj(C, volume)
				cdel(C)

	reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(C.r_hand)
				C.r_hand.clean_blood()
			if(C.l_hand)
				C.l_hand.clean_blood()
			if(C.wear_mask)
				if(C.wear_mask.clean_blood())
					C.update_inv_wear_mask(0)
			if(ishuman(M))
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
			M.clean_blood()

	on_overdose(mob/living/M)
		M.apply_damage(2, TOX) //Overdose starts getting bad

	on_overdose_critical(mob/living/M)
		M.apply_damage(3, TOX) //Overdose starts getting bad

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	description = "Cryptobiolin causes confusion and dizzyness."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.make_dizzy(1)
		if(!M.confused) M.confused = 1
		M.confused = max(M.confused, 20)
		holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)

	on_overdose(mob/living/M)
		M.apply_damage(2, TOX) //Overdose starts getting bad

	on_overdose_critical(mob/living/M)
		M.apply_damage(3, TOX) //Overdose starts getting bad

/datum/reagent/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL

	on_mob_life(mob/living/M)
		. = ..()
		if(!.) return
		M.jitteriness = max(M.jitteriness - 5,0)
		if(prob(80)) M.adjustBrainLoss(REM)
		if(prob(50)) M.drowsyness = max(M.drowsyness, 3)
		if(prob(10)) M.emote("drool")

	on_overdose(mob/living/M)
		M.apply_damage(2, TOX) //Overdose starts getting bad

	on_overdose_critical(mob/living/M)
		M.apply_damage(3, TOX) //Overdose starts getting bad


///////////////////////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/nanites
	name = "Nanomachines"
	id = "nanites"
	description = "Microscopic construction robots."
	reagent_state = LIQUID
	color = "#535E66" // rgb: 83, 94, 102

	reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
		src = null
		if( (prob(10) && method==TOUCH) || method==INGEST)
			M.contract_disease(new /datum/disease/robotic_transformation(0),1)

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	reagent_state = LIQUID
	color = "#535E66" // rgb: 83, 94, 102

	reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
		src = null
		if( (prob(10) && method==TOUCH) || method==INGEST)
			M.contract_disease(new /datum/disease/xeno_transformation(0),1)

/datum/reagent/fluorosurfactant//foam precursor
	name = "Fluorosurfactant"
	id = "fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	reagent_state = LIQUID
	color = "#9E6B38" // rgb: 158, 107, 56

/datum/reagent/foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
	name = "Foaming agent"
	id = "foaming_agent"
	description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99

/datum/reagent/nicotine
	name = "Nicotine"
	id = "nicotine"
	description = "A highly addictive stimulant extracted from the tobacco plant."
	reagent_state = LIQUID
	color = "#181818" // rgb: 24, 24, 24

/datum/reagent/ammonia
	name = "Ammonia"
	id = "ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48

/datum/reagent/ultraglue
	name = "Ultra Glue"
	id = "glue"
	description = "An extremely powerful bonding agent."
	color = "#FFFFCC" // rgb: 255, 255, 204

/datum/reagent/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	description = "A secondary amine, mildly corrosive."
	reagent_state = LIQUID
	color = "#604030" // rgb: 96, 64, 48



/datum/reagent/blackgoo
	name = "Black goo"
	id = "blackgoo"
	description = "A strange dark liquid of unknown origin and effect."
	reagent_state = LIQUID
	color = "#222222"
	custom_metabolism = 100 //disappears immediately

	on_mob_life(mob/living/M)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species.name == "Human")
				H.contract_disease(new /datum/disease/black_goo, 1)
		. = ..()

	reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species.name == "Human")
				H.contract_disease(new /datum/disease/black_goo)

	reaction_turf(var/turf/T, var/volume)
		if(!istype(T)) return
		if(volume < 3) return
		if(!(locate(/obj/effect/decal/cleanable/blackgoo) in T))
			new /obj/effect/decal/cleanable/blackgoo(T)
