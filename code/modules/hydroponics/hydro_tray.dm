#define HYDRO_SPEED_MULTIPLIER 1

/obj/machinery/portable_atmospherics/hydroponics
	name = "hydroponics tray"
	icon = 'icons/obj/machines/hydroponics.dmi'
	icon_state = "hydrotray3"
	density = TRUE
	anchored = TRUE
	volume = 100
	coverage = 20
	layer = BELOW_OBJ_LAYER
	resistance_flags = XENO_DAMAGEABLE
	max_integrity = 40

	var/draw_warnings = 1 //Set to 0 to stop it from drawing the alert lights.

	// Plant maintenance vars.
	var/waterlevel = 100       // Water (max 100)
	var/nutrilevel = 100       // Nutrient (max 100)
	var/pestlevel = 0          // Pests (max 10)
	var/weedlevel = 0          // Weeds (max 10)

	// Tray state vars.
	var/dead = 0               // Is it dead?
	var/harvest = 0            // Is it ready to harvest?
	var/age = 0                // Current plant age
	var/sampled = 0            // Have wa taken a sample?

	// Harvest/mutation mods.
	var/yield_mod = 0          // Modifier to yield
	var/mutation_mod = 0       // Modifier to mutation chance
	var/toxins = 0             // Toxicity in the tray?
	var/mutation_level = 0     // When it hits 100, the plant mutates.

	// Mechanical concerns.
	var/health = 0             // Plant health.
	var/lastproduce = 0        // Last time tray was harvested
	var/lastcycle = 0          // Cycle timing/tracking var.
	var/cycledelay = 150       // Delay per cycle.
	var/closed_system          // If set, the tray will attempt to take atmos from a pipe.
	var/force_update           // Set this to bypass the cycle time check.
	var/obj/temp_chem_holder   // Something to hold reagents during process_reagents()

	// Seed details/line data.
	var/datum/seed/seed = null // The currently planted seed

	// Reagent information for process(), consider moving this to a controller along
	// with cycle information under 'mechanical concerns' at some point.
	var/global/list/toxic_reagents = list(
		/datum/reagent/medicine/dylovene =     -2,
		/datum/reagent/toxin =           2,
		/datum/reagent/fluorine =        2.5,
		/datum/reagent/chlorine =        1.5,
		/datum/reagent/toxin/acid =           1.5,
		/datum/reagent/toxin/acid/polyacid =           3,
		/datum/reagent/toxin/plantbgone =      3,
		/datum/reagent/medicine/cryoxadone =     -3,
		/datum/reagent/radium =          2
		)
	var/global/list/nutrient_reagents = list(
		/datum/reagent/consumable/drink/milk =            0.1,
		/datum/reagent/consumable/ethanol/beer =            0.25,
		/datum/reagent/phosphorus =      0.1,
		/datum/reagent/consumable/sugar =           0.1,
		/datum/reagent/consumable/drink/cold/sodawater =       0.1,
		/datum/reagent/ammonia =         1,
		/datum/reagent/diethylamine =    2,
		/datum/reagent/consumable/nutriment =       1,
		/datum/reagent/medicine/adminordrazine =  1,
		/datum/reagent/toxin/fertilizer/eznutrient =      1,
		/datum/reagent/toxin/fertilizer/robustharvest =   1,
		/datum/reagent/toxin/fertilizer/left4zed =        1
		)
	var/global/list/weedkiller_reagents = list(
		/datum/reagent/fluorine =       -4,
		/datum/reagent/chlorine =       -3,
		/datum/reagent/phosphorus =     -2,
		/datum/reagent/consumable/sugar =           2,
		/datum/reagent/toxin/acid =          -2,
		/datum/reagent/toxin/acid/polyacid =          -4,
		/datum/reagent/toxin/plantbgone =     -8,
		/datum/reagent/medicine/adminordrazine = -5
		)
	var/global/list/pestkiller_reagents = list(
		/datum/reagent/consumable/sugar =           2,
		/datum/reagent/diethylamine =   -2,
		/datum/reagent/medicine/adminordrazine = -5
		)
	var/global/list/water_reagents = list(
		/datum/reagent/water =           1,
		/datum/reagent/medicine/adminordrazine =  1,
		/datum/reagent/consumable/drink/milk =            0.9,
		/datum/reagent/consumable/ethanol/beer =            0.7,
		/datum/reagent/fluorine =       -0.5,
		/datum/reagent/chlorine =       -0.5,
		/datum/reagent/phosphorus =     -0.5,
		/datum/reagent/water =           1,
		/datum/reagent/consumable/drink/cold/sodawater =       1,
		)

	// Beneficial reagents also have values for modifying yield_mod and mut_mod (in that order).
	var/global/list/beneficial_reagents = list(
		/datum/reagent/consumable/ethanol/beer =           list( -0.05, 0,   0   ),
		/datum/reagent/fluorine =       list( -2,    0,   0   ),
		/datum/reagent/chlorine =       list( -1,    0,   0   ),
		/datum/reagent/phosphorus =     list( -0.75, 0,   0   ),
		/datum/reagent/consumable/drink/cold/sodawater =      list(  0.1,  0,   0   ),
		/datum/reagent/toxin/acid =          list( -1,    0,   0   ),
		/datum/reagent/toxin/acid/polyacid =          list( -2,    0,   0   ),
		/datum/reagent/toxin/plantbgone =     list( -2,    0,   0.2 ),
		/datum/reagent/medicine/cryoxadone =     list(  3,    0,   0   ),
		/datum/reagent/ammonia =        list(  0.5,  0,   0   ),
		/datum/reagent/diethylamine =   list(  1,    0,   0   ),
		/datum/reagent/consumable/nutriment =      list(  0.5,  0.1,   0 ),
		/datum/reagent/radium =         list( -1.5,  0,   0.2 ),
		/datum/reagent/medicine/adminordrazine = list(  1,    1,   1   ),
		/datum/reagent/toxin/fertilizer/robustharvest =  list(  0,    0.2, 0   ),
		/datum/reagent/toxin/fertilizer/left4zed =       list(  0,    0,   0.2 )
		)

	// Mutagen list specifies minimum value for the mutation to take place, rather
	// than a bound as the lists above specify.
	var/global/list/mutagenic_reagents = list(
		/datum/reagent/radium =  8,
		/datum/reagent/toxin/mutagen = 15
		)

/obj/machinery/portable_atmospherics/hydroponics/Initialize()
	. = ..()
	temp_chem_holder = new()
	temp_chem_holder.create_reagents(10)
	create_reagents(200, AMOUNT_VISIBLE|REFILLABLE)
	connect()
	update_icon()
	start_processing()


/obj/machinery/portable_atmospherics/hydroponics/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover) && CHECK_BITFIELD(mover.flags_pass, PASSTABLE))
		return TRUE

/obj/machinery/portable_atmospherics/hydroponics/process()

	//Do this even if we're not ready for a plant cycle.
	process_reagents()

	// Update values every cycle rather than every process() tick.
	if(force_update)
		force_update = 0
	else if(world.time < (lastcycle + cycledelay))
		return
	lastcycle = world.time

	// Mutation level drops each main tick.
	mutation_level -= rand(2,4)

	// Weeds like water and nutrients, there's a chance the weed population will increase.
	// Bonus chance if the tray is unoccupied.
	if(waterlevel > 10 && nutrilevel > 2 && prob(isnull(seed) ? 5 : 1))
		weedlevel += 1 * HYDRO_SPEED_MULTIPLIER

	// There's a chance for a weed explosion to happen if the weeds take over.
	// Plants that are themselves weeds (weed_tolerance > 10) are unaffected.
	if (weedlevel >= 10 && prob(10))
		if(!seed || weedlevel >= seed.weed_tolerance)
			weed_invasion()

	// If there is no seed data (and hence nothing planted),
	// or the plant is dead, process nothing further.
	if(!seed || dead)
		if(draw_warnings) update_icon() //Harvesting would fail to set alert icons properly.
		return

	// Advance plant age.
	if(prob(30)) age += 1 * HYDRO_SPEED_MULTIPLIER

	//Highly mutable plants have a chance of mutating every tick.
	if(seed.immutable == -1)
		var/mut_prob = rand(1,100)
		if(mut_prob <= 5) mutate(mut_prob == 1 ? 2 : 1)

	// Other plants also mutate if enough mutagenic compounds have been added.
	if(!seed.immutable)
		if(prob(min(mutation_level,100)))
			mutate((rand(100) < 15) ? 2 : 1)
			mutation_level = 0

	// Maintain tray nutrient and water levels.
	if(seed.nutrient_consumption > 0 && nutrilevel > 0 && prob(25))
		nutrilevel -= max(0,seed.nutrient_consumption * HYDRO_SPEED_MULTIPLIER)
	if(seed.water_consumption > 0 && waterlevel > 0  && prob(25))
		waterlevel -= max(0,seed.water_consumption * HYDRO_SPEED_MULTIPLIER)

	// Make sure the plant is not starving or thirsty. Adequate
	// water and nutrients will cause a plant to become healthier.
	var/healthmod = rand(1,3) * HYDRO_SPEED_MULTIPLIER
	if(seed.requires_nutrients && prob(35))
		health += (nutrilevel < 2 ? -healthmod : healthmod)
	if(seed.requires_water && prob(35))
		health += (waterlevel < 10 ? -healthmod : healthmod)

	// Check that pressure, heat and light are all within bounds.
	// First, handle an open system or an unconnected closed system.

	// Process it.
//	if(pressure < seed.lowkpa_tolerance || pressure > seed.highkpa_tolerance)
//		health -= healthmod

//	if(abs(temperature - seed.ideal_heat) > seed.heat_tolerance)
//		health -= healthmod

	// If we're attached to a pipenet, then we should let the pipenet know we might have modified some gasses
//	if (closed_system && connected_port)
//		update_connected_network()

	// Toxin levels beyond the plant's tolerance cause damage, but
	// toxins are sucked up each tick and slowly reduce over time.
	if(toxins > 0)
		var/toxin_uptake = max(1,round(toxins/10))
		if(toxins > seed.toxins_tolerance)
			health -= toxin_uptake
		toxins -= toxin_uptake

	// Check for pests and weeds.
	// Some carnivorous plants happily eat pests.
	if(pestlevel > 0)
		if(seed.carnivorous)
			health += HYDRO_SPEED_MULTIPLIER
			pestlevel -= HYDRO_SPEED_MULTIPLIER
		else if (pestlevel >= seed.pest_tolerance)
			health -= HYDRO_SPEED_MULTIPLIER

	// Some plants thrive and live off of weeds.
	if(weedlevel > 0)
		if(seed.parasite)
			health += HYDRO_SPEED_MULTIPLIER
			weedlevel -= HYDRO_SPEED_MULTIPLIER
		else if (weedlevel >= seed.weed_tolerance)
			health -= HYDRO_SPEED_MULTIPLIER

	// Handle life and death.
	// If the plant is too old, it loses health fast.
	if(age > seed.lifespan)
		health -= rand(3,5) * HYDRO_SPEED_MULTIPLIER

	// When the plant dies, weeds thrive and pests die off.
	if(health <= 0)
		dead = 1
		mutation_level = 0
		harvest = 0
		weedlevel += 1 * HYDRO_SPEED_MULTIPLIER
		pestlevel = 0

	// If enough time (in cycles, not ticks) has passed since the plant was harvested, we're ready to harvest again.
	else if(seed.products && seed.products.len && age > seed.production && \
	(age - lastproduce) > seed.production && (!harvest && !dead))
		harvest = 1
		lastproduce = age

	if(prob(3))  // On each tick, there's a chance the pest population will increase
		pestlevel += 0.1 * HYDRO_SPEED_MULTIPLIER

	check_level_sanity()
	update_icon()

//Process reagents being input into the tray.
/obj/machinery/portable_atmospherics/hydroponics/proc/process_reagents()

	if(!reagents)
		return

	if(reagents.total_volume <= 0)
		return

	reagents.trans_to(temp_chem_holder, min(reagents.total_volume,rand(1,3)))

	for(var/datum/reagent/R in temp_chem_holder.reagents.reagent_list)

		var/reagent_total = temp_chem_holder.reagents.get_reagent_amount(R.type)

		if(seed && !dead)
			//Handle some general level adjustments.
			if(toxic_reagents[R.type])
				toxins += toxic_reagents[R.type]         * reagent_total
			if(weedkiller_reagents[R.type])
				weedlevel -= weedkiller_reagents[R.type] * reagent_total
			if(pestkiller_reagents[R.type])
				pestlevel += pestkiller_reagents[R.type] * reagent_total

			// Beneficial reagents have a few impacts along with health buffs.
			if(beneficial_reagents[R.type])
				health += beneficial_reagents[R.type][1]       * reagent_total
				yield_mod += beneficial_reagents[R.type][2]    * reagent_total
				mutation_mod += beneficial_reagents[R.type][3] * reagent_total

			// Mutagen is distinct from the previous types and mostly has a chance of proccing a mutation.
			if(mutagenic_reagents[R.type])
				mutation_level += reagent_total*mutagenic_reagents[R.type]+mutation_mod

		// Handle nutrient refilling.
		if(nutrient_reagents[R.type])
			nutrilevel += nutrient_reagents[R.type]  * reagent_total

		// Handle water and water refilling.
		var/water_added = 0
		if(water_reagents[R.type])
			var/water_input = water_reagents[R.type] * reagent_total
			water_added += water_input
			waterlevel += water_input

		// Water dilutes toxin level.
		if(water_added > 0)
			toxins -= round(water_added/4)

	temp_chem_holder.reagents.clear_reagents()
	check_level_sanity()
	update_icon()

//Harvests the product of a plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/harvest(mob/user)

	//Harvest the product of the plant,
	if(!seed || !harvest || !user)
		return

	if(closed_system)
		to_chat(user, "You can't harvest from the plant while the lid is shut.")
		return

	seed.harvest(user,yield_mod)

	// Reset values.
	harvest = 0
	lastproduce = age

	if(!seed.harvest_repeat)
		yield_mod = 0
		seed = null
		dead = 0
		age = 0
		sampled = 0
		mutation_mod = 0

	check_level_sanity()
	update_icon()

//Clears out a dead plant.
/obj/machinery/portable_atmospherics/hydroponics/proc/remove_dead(mob/user)
	if(!user || !dead)
		return

	if(closed_system)
		to_chat(user, "You can't remove the dead plant while the lid is shut.")
		return

	seed = null
	dead = 0
	sampled = 0
	age = 0
	yield_mod = 0
	mutation_mod = 0

	to_chat(user, "You remove the dead plant from the [src].")
	check_level_sanity()
	update_icon()

//Refreshes the icon and sets the luminosity
/obj/machinery/portable_atmospherics/hydroponics/update_icon()

	overlays.Cut()

	// Updates the plant overlay.
	if(!isnull(seed))

		if(draw_warnings && health <= (seed.endurance / 2))
			overlays += "over_lowhealth3"

		if(dead)
			overlays += "[seed.plant_icon]-dead"
		else if(harvest)
			overlays += "[seed.plant_icon]-harvest"
		else if(age < seed.maturation)

			var/t_growthstate
			if(age >= seed.maturation)
				t_growthstate = seed.growth_stages
			else
				t_growthstate = round(seed.maturation / seed.growth_stages)

			overlays += "[seed.plant_icon]-grow[t_growthstate]"
			lastproduce = age
		else
			overlays += "[seed.plant_icon]-grow[seed.growth_stages]"

	//Draw the cover.
	if(closed_system)
		overlays += "hydrocover"

	//Updated the various alert icons.
	if(draw_warnings)
		if(waterlevel <= 10)
			overlays += "over_lowwater3"
		if(nutrilevel <= 2)
			overlays += "over_lownutri3"
		if(weedlevel >= 5 || pestlevel >= 5 || toxins >= 40)
			overlays += "over_alert3"
		if(harvest)
			overlays += "over_harvest3"

	// Update bioluminescence.
	if(seed)
		if(seed.biolum)
			if(seed.biolum_colour)
				set_light(round(seed.potency / 10), l_color = seed.biolum_colour)
			else
				set_light(round(seed.potency / 10))
			return

	set_light(0)


// If a weed growth is sufficient, this proc is called.
/obj/machinery/portable_atmospherics/hydroponics/proc/weed_invasion()

	//Remove the seed if something is already planted.
	if(seed) seed = null
	seed = GLOB.seed_types[pick(list("reishi","nettles","amanita","mushrooms","plumphelmet","towercap","harebells","weeds"))]
	if(!seed)
		return //Weed does not exist, someone fucked up.

	dead = 0
	age = 0
	health = seed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0
	pestlevel = 0
	sampled = 0
	update_icon()
	visible_message(span_notice(" [src] has been overtaken by [seed.display_name]."))


/obj/machinery/portable_atmospherics/hydroponics/proc/mutate(severity)

	// No seed, no mutations.
	if(!seed)
		return

	// Check if we should even bother working on the current seed datum.
	if(seed.mutants && seed.mutants.len && severity > 1)
		mutate_species()
		return

	// We need to make sure we're not modifying one of the global seed datums.
	// If it's not in the global list, then no products of the line have been
	// harvested yet and it's safe to assume it's restricted to this tray.
	if(!isnull(GLOB.seed_types[seed.name]))
		seed = seed.diverge()
	seed.mutate(severity,get_turf(src))


/obj/machinery/portable_atmospherics/hydroponics/proc/check_level_sanity()
	//Make sure various values are sane.
	if(seed)
		health =     max(0,min(seed.endurance,health))
	else
		health = 0
		dead = 0

	mutation_level = max(0,min(mutation_level,100))
	nutrilevel =     max(0,min(nutrilevel,10))
	waterlevel =     max(0,min(waterlevel,100))
	pestlevel =      max(0,min(pestlevel,10))
	weedlevel =      max(0,min(weedlevel,10))
	toxins =         max(0,min(toxins,10))

/obj/machinery/portable_atmospherics/hydroponics/proc/mutate_species()

	var/previous_plant = seed.display_name
	var/newseed = seed.get_mutant_variant()
	seed = GLOB.seed_types[newseed] || seed

	dead = 0
	mutate(1)
	age = 0
	health = seed.endurance
	lastcycle = world.time
	harvest = 0
	weedlevel = 0

	update_icon()
	visible_message(span_warning(" The <span class='notice'> [previous_plant] <span class='warning'> has suddenly mutated into <span class='notice'> [seed.display_name]!"))


/obj/machinery/portable_atmospherics/hydroponics/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(I.is_open_container())
		return

	else if(iswirecutter(I) || istype(I, /obj/item/tool/surgery/scalpel))
		if(!seed)
			to_chat(user, "There is nothing to take a sample from in \the [src].")
			return

		if(sampled)
			to_chat(user, "You have already sampled from this plant.")
			return

		if(dead)
			to_chat(user, "The plant is dead.")
			return

		// Create a sample.
		seed.harvest(user, yield_mod, 1)
		health -= (rand(3, 5) * 10)

		if(prob(30))
			sampled = TRUE

		// Bookkeeping.
		check_level_sanity()
		force_update = TRUE
		process()

	else if(istype(I, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = I
		if(S.mode == 1)
			if(seed)
				return FALSE
			to_chat(user, "There's no plant to inject.")
			return TRUE
		else
			if(seed)
				to_chat(user, "You can't get any extract out of this plant.")
			else
				to_chat(user, "There's nothing to draw something from.")
			return TRUE

	else if(istype(I, /obj/item/seeds))
		var/obj/item/seeds/S = I

		if(seed)
			to_chat(user, span_warning("\The [src] already has seeds in it!"))
			return

		user.drop_held_item()

		if(!S.seed)
			to_chat(user, "The packet seems to be empty. You throw it away.")
			qdel(I)
			return

		to_chat(user, "You plant the [S.seed.seed_name] [S.seed.seed_noun].")

		if(S.seed.spread == 1)
			message_admins("[key_name(user)] has planted a creeper packet.")
			var/obj/effect/plant_controller/creeper/PC = new(get_turf(src))
			if(PC)
				PC.seed = S.seed
		else if(S.seed.spread == 2)
			message_admins("[key_name(user)] has planted a spreading vine packet.")
			var/obj/effect/plant_controller/PC = new(get_turf(src))
			if(PC)
				PC.seed = S.seed
		else
			seed = S.seed //Grab the seed datum.
			dead = FALSE
			age = 1
			//Snowflakey, maybe move this to the seed datum
			health = seed.endurance
			lastcycle = world.time

		qdel(I)

		check_level_sanity()
		update_icon()

	else if(istype(I, /obj/item/tool/minihoe))  // The minihoe
		if(weedlevel <= 0)
			to_chat(user, span_warning("This plot is completely devoid of weeds. It doesn't need uprooting."))
			return

		user.visible_message(span_warning(" [user] starts uprooting the weeds."), span_warning(" You remove the weeds from the [src]."))
		weedlevel = 0
		update_icon()

	else if(istype(I, /obj/item/storage/bag/plants))
		var/obj/item/storage/bag/plants/S = I

		attack_hand(user)
		for(var/obj/item/reagent_containers/food/snacks/grown/G in user.loc)
			if(!S.can_be_inserted(G))
				return
			S.handle_item_insertion(G, TRUE, user)

	else if(istype(I, /obj/item/tool/plantspray))
		var/obj/item/tool/plantspray/spray = I
		user.drop_held_item()
		toxins += spray.toxicity
		pestlevel -= spray.pest_kill_str
		weedlevel -= spray.weed_kill_str
		to_chat(user, "You spray [src] with [I].")
		playsound(loc, 'sound/effects/spray3.ogg', 25, 1, 3)
		qdel(I)

		check_level_sanity()
		update_icon()

	else if(iswrench(I))
		playsound(loc, 'sound/items/ratchet.ogg', 25, 1)
		anchored = !anchored
		to_chat(user, "You [anchored ? "wrench" : "unwrench"] \the [src].")


/obj/machinery/portable_atmospherics/hydroponics/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(harvest)
		harvest(user)
	else if(dead)
		remove_dead(user)

	else
		if(seed && !dead)
			to_chat(usr, "[src] has [span_notice(" [seed.display_name] \black planted.")]")
			if(health <= (seed.endurance / 2))
				to_chat(usr, "The plant looks [span_warning(" unhealthy.")]")
		else
			to_chat(usr, "[src] is empty.")
		to_chat(usr, "Water: [round(waterlevel,0.1)]/100")
		to_chat(usr, "Nutrient: [round(nutrilevel,0.1)]/10")
		if(weedlevel >= 5)
			to_chat(usr, "[src] is [span_warning(" filled with weeds!")]")
		if(pestlevel >= 5)
			to_chat(usr, "[src] is [span_warning(" filled with tiny worms!")]")


/obj/machinery/portable_atmospherics/hydroponics/verb/close_lid()
	set name = "Toggle Tray Lid"
	set category = "Object"
	set src in view(1)

	if(!usr || usr.stat || usr.restrained())
		return

	closed_system = !closed_system
	to_chat(usr, "You [closed_system ? "close" : "open"] the tray's lid.")
	update_icon()

/obj/machinery/portable_atmospherics/hydroponics/soil
	name = "soil"
	icon = 'icons/obj/machines/hydroponics.dmi'
	icon_state = "soil"
	density = FALSE
	use_power = 0
	draw_warnings = 0

/obj/machinery/portable_atmospherics/hydroponics/soil/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/tool/shovel))
		to_chat(user, "You clear up [src]!")
		qdel(src)

/obj/machinery/portable_atmospherics/hydroponics/soil/Initialize()
	. = ..()
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/close_lid

#undef HYDRO_SPEED_MULTIPLIER
