//Analyzer, pestkillers, weedkillers, nutrients, hatchets, cutters.

/obj/item/tool/wirecutters/clippers
	name = "plant clippers"
	desc = "A tool used to take samples from plants."

/obj/item/tool/analyzer/plant_analyzer
	name = "plant analyzer"
	icon_state = "hydro"
	item_state = "analyzer"

/obj/item/tool/analyzer/plant_analyzer/attack_self(mob/user as mob)
	return 0

/obj/item/tool/analyzer/plant_analyzer/afterattack(obj/target, mob/user, flag)
	if(!flag) return

	var/datum/seed/grown_seed
	var/datum/reagents/grown_reagents
	if(istype(target,/obj/structure/rack) || istype(target,/obj/structure/table))
		return ..()
	else if(istype(target,/obj/item/reagent_containers/food/snacks/grown))

		var/obj/item/reagent_containers/food/snacks/grown/G = target
		grown_seed = GLOB.seed_types[G.plantname]
		grown_reagents = G.reagents

	else if(istype(target,/obj/item/grown))

		var/obj/item/grown/G = target
		grown_seed = GLOB.seed_types[G.plantname]
		grown_reagents = G.reagents

	else if(istype(target,/obj/item/seeds))

		var/obj/item/seeds/S = target
		grown_seed = S.seed

	else if(istype(target,/obj/machinery/hydroponics))

		var/obj/machinery/hydroponics/H = target
		grown_seed = H.seed
		grown_reagents = H.reagents

	if(!grown_seed)
		to_chat(user, span_warning("[src] can tell you nothing about [target]."))
		return

	var/dat
	user.visible_message(span_notice(" [user] runs the scanner over [target]."))

	dat += "<h2>General Data</h2>"

	dat += "<table>"
	dat += "<tr><td><b>Endurance</b></td><td>[grown_seed.endurance]</td></tr>"
	dat += "<tr><td><b>Yield</b></td><td>[grown_seed.yield]</td></tr>"
	dat += "<tr><td><b>Lifespan</b></td><td>[grown_seed.lifespan]</td></tr>"
	dat += "<tr><td><b>Maturation time</b></td><td>[grown_seed.maturation]</td></tr>"
	dat += "<tr><td><b>Production time</b></td><td>[grown_seed.production]</td></tr>"
	dat += "<tr><td><b>Potency</b></td><td>[grown_seed.potency]</td></tr>"
	dat += "</table>"

	if(length(grown_reagents.reagent_list))
		dat += "<h2>Reagent Data</h2>"

		dat += "<br>This sample contains: "
		for(var/datum/reagent/R in grown_reagents.reagent_list)
			dat += "<br>- [R.name], [grown_reagents.get_reagent_amount(R.type)] unit(s)"

	dat += "<h2>Other Data</h2>"

	if(grown_seed.harvest_repeat)
		dat += "This plant can be harvested repeatedly.<br>"

	if(grown_seed.immutable == -1)
		dat += "This plant is highly mutable.<br>"
	else if(grown_seed.immutable > 0)
		dat += "This plant does not possess genetics that are alterable.<br>"

	if(grown_seed.products && length(grown_seed.products))
		dat += "The mature plant will produce [length(grown_seed.products) == 1 ? "fruit" : "[length(grown_seed.products)] varieties of fruit"].<br>"

	if(grown_seed.requires_nutrients)
		if(grown_seed.nutrient_consumption < 0.05)
			dat += "It consumes a small amount of nutrient fluid.<br>"
		else if(grown_seed.nutrient_consumption > 0.2)
			dat += "It requires a heavy supply of nutrient fluid.<br>"
		else
			dat += "It requires a supply of nutrient fluid.<br>"

	if(grown_seed.requires_water)
		if(grown_seed.water_consumption < 1)
			dat += "It requires very little water.<br>"
		else if(grown_seed.water_consumption > 5)
			dat += "It requires a large amount of water.<br>"
		else
			dat += "It requires a stable supply of water.<br>"

	if(grown_seed.mutants && length(grown_seed.mutants))
		dat += "It exhibits a high degree of potential subspecies shift.<br>"

	dat += "It thrives in a temperature of [grown_seed.ideal_heat] Kelvin."

	if(grown_seed.lowkpa_tolerance < 20)
		dat += "<br>It is well adapted to low pressure levels."
	if(grown_seed.highkpa_tolerance > 220)
		dat += "<br>It is well adapted to high pressure levels."

	if(grown_seed.heat_tolerance > 30)
		dat += "<br>It is well adapted to a range of temperatures."
	else if(grown_seed.heat_tolerance < 10)
		dat += "<br>It is very sensitive to temperature shifts."

	dat += "<br>It thrives in a light level of [grown_seed.ideal_light] lumen[grown_seed.ideal_light == 1 ? "" : "s"]."

	if(grown_seed.light_tolerance > 10)
		dat += "<br>It is well adapted to a range of light levels."
	else if(grown_seed.light_tolerance < 3)
		dat += "<br>It is very sensitive to light level shifts."

	if(grown_seed.toxins_tolerance < 3)
		dat += "<br>It is highly sensitive to toxins."
	else if(grown_seed.toxins_tolerance > 6)
		dat += "<br>It is remarkably resistant to toxins."

	if(grown_seed.pest_tolerance < 3)
		dat += "<br>It is highly sensitive to pests."
	else if(grown_seed.pest_tolerance > 6)
		dat += "<br>It is remarkably resistant to pests."

	if(grown_seed.weed_tolerance < 3)
		dat += "<br>It is highly sensitive to weeds."
	else if(grown_seed.weed_tolerance > 6)
		dat += "<br>It is remarkably resistant to weeds."

	switch(grown_seed.spread)
		if(1)
			dat += "<br>It is capable of growing beyond the confines of a tray."
		if(2)
			dat += "<br>It is a robust and vigorous vine that will spread rapidly."

	switch(grown_seed.carnivorous)
		if(1)
			dat += "<br>It is carniovorous and will eat tray pests for sustenance."
		if(2)
			dat	+= "<br>It is carnivorous and poses a significant threat to living things around it."

	if(grown_seed.parasite)
		dat += "<br>It is capable of parisitizing and gaining sustenance from tray weeds."
	if(grown_seed.alter_temp)
		dat += "<br>It will periodically alter the local temperature by [grown_seed.alter_temp] degrees Kelvin."

	if(grown_seed.biolum)
		dat += "<br>It is [grown_seed.biolum_colour ? "<font color='[grown_seed.biolum_colour]'>bio-luminescent</font>" : "bio-luminescent"]."
	if(grown_seed.flowers)
		dat += "<br>It has [grown_seed.flower_colour ? "<font color='[grown_seed.flower_colour]'>flowers</font>" : "flowers"]."

	var/datum/browser/popup = new(user, "plant_analyzer", "<div align='center'>Plant data for [target]</div>")
	popup.set_content(dat)
	popup.open()



// *************************************
// Nutrient defines for hydroponics
// *************************************

/obj/item/reagent_containers/glass/fertilizer
	name = "fertilizer bottle"
	desc = "A small glass bottle. Can hold up to 10 units."
	icon = 'icons/obj/items/chemistry.dmi'
	icon_state = "bottle16"
	possible_transfer_amounts = null
	w_class = WEIGHT_CLASS_SMALL

	var/fertilizer //Reagent contained, if any.

	//Like a shot glass!
	amount_per_transfer_from_this = 10
	volume = 10


/obj/item/reagent_containers/glass/fertilizer/Initialize(mapload)
	. = ..()

	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	if(fertilizer)
		reagents.add_reagent(fertilizer,10)


/obj/item/reagent_containers/glass/fertilizer/ez
	name = "bottle of E-Z-Nutrient"
	icon_state = "bottle16"
	fertilizer = /datum/reagent/toxin/fertilizer/eznutrient

/obj/item/reagent_containers/glass/fertilizer/l4z
	name = "bottle of Left 4 Zed"
	icon_state = "bottle18"
	fertilizer = /datum/reagent/toxin/fertilizer/left4zed

/obj/item/reagent_containers/glass/fertilizer/rh
	name = "bottle of Robust Harvest"
	icon_state = "bottle15"
	fertilizer = /datum/reagent/toxin/fertilizer/robustharvest
