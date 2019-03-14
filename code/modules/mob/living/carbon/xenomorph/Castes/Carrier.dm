/datum/xeno_caste/carrier
	caste_name = "Carrier"
	display_name = "Carrier"
	upgrade_name = "Young"
	caste_desc = "A carrier of huggies."

	caste_type_path = /mob/living/carbon/Xenomorph/Carrier

	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO

	// *** Melee Attacks *** //
	melee_damage_lower = 20
	melee_damage_upper = 30

	// *** Tackle *** //
	tackle_damage = 30

	// *** Speed *** //
	speed = 0

	// *** Plasma *** //
	plasma_max = 250
	plasma_gain = 8

	// *** Health *** //
	max_health = 200

	// *** Evolution *** //
	evolution_threshold = 200
	upgrade_threshold = 200

	deevolves_to = /mob/living/carbon/Xenomorph/Drone

	evolves_to = list(/mob/living/carbon/Xenomorph/Defiler)

	// *** Flags *** //
	caste_flags = CASTE_CAN_BE_QUEEN_HEALED|CASTE_EVOLUTION_ALLOWED|CASTE_CAN_HOLD_FACEHUGGERS|CASTE_CAN_BE_GIVEN_PLASMA|CASTE_CAN_BE_LEADER
	can_hold_eggs = CAN_HOLD_ONE_HAND

	// *** Defense *** //
	armor_deflection = 5

	// *** Pheromones *** //
	aura_strength = 1.5
	aura_allowed = list("frenzy", "warding", "recovery")

	// *** Carrier Abilities *** //
	huggers_max = 8
	hugger_delay = 2.5 SECONDS
	eggs_max = 3

/datum/xeno_caste/carrier/mature
	upgrade_name = "Mature"
	caste_desc = "A portable Love transport. It looks a little more dangerous."

	upgrade = XENO_UPGRADE_ONE

	// *** Melee Attacks *** //
	melee_damage_lower = 25
	melee_damage_upper = 35

	// *** Tackle *** //
	tackle_damage = 35

	// *** Speed *** //
	speed = -0.1

	// *** Plasma *** //
	plasma_max = 300
	plasma_gain = 10

	// *** Health *** //
	max_health = 220

	// *** Evolution *** //
	upgrade_threshold = 400

	// *** Defense *** //
	armor_deflection = 10

	// *** Pheromones *** //
	aura_strength = 2

	// *** Carrier Abilities *** //
	huggers_max = 9
	hugger_delay = 2.0 SECONDS
	eggs_max = 4

/datum/xeno_caste/carrier/elite
	upgrade_name = "Elite"
	caste_desc = "A portable Love transport. It looks pretty strong."

	upgrade = XENO_UPGRADE_TWO

	// *** Melee Attacks *** //
	melee_damage_lower = 30
	melee_damage_upper = 40

	// *** Tackle *** //
	tackle_damage = 40

	// *** Speed *** //
	speed = -0.2

	// *** Plasma *** //
	plasma_max = 350
	plasma_gain = 12

	// *** Health *** //
	max_health = 220

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 10

	// *** Pheromones *** //
	aura_strength = 2.3

	// *** Carrier Abilities *** //
	huggers_max = 10
	hugger_delay = 1.5 SECONDS
	eggs_max = 5

/datum/xeno_caste/carrier/ancient
	upgrade_name = "Ancient"
	caste_desc = "It's literally crawling with 11 huggers."
	upgrade = XENO_UPGRADE_THREE
	ancient_message = "You are the master of huggers. Throw them like baseballs at the marines!"

	// *** Melee Attacks *** //
	melee_damage_lower = 35
	melee_damage_upper = 45

	// *** Tackle *** //
	tackle_damage = 45

	// *** Speed *** //
	speed = -0.3

	// *** Plasma *** //
	plasma_max = 400
	plasma_gain = 15

	// *** Health *** //
	max_health = 250

	// *** Evolution *** //
	upgrade_threshold = 800

	// *** Defense *** //
	armor_deflection = 15

	// *** Pheromones *** //
	aura_strength = 2.5

	// *** Carrier Abilities *** //
	huggers_max = 11
	hugger_delay = 1.0 SECONDS
	eggs_max = 6

/mob/living/carbon/Xenomorph/Carrier
	caste_base_type = /mob/living/carbon/Xenomorph/Carrier
	name = "Carrier"
	desc = "A strange-looking alien creature. It carries a number of scuttling jointed crablike creatures."
	icon = 'icons/Xeno/2x2_Xenos.dmi' //They are now like, 2x2
	icon_state = "Carrier Walking"
	health = 200
	maxHealth = 200
	plasma_stored = 50
	drag_delay = 6 //pulling a big dead xeno is hard
	speed = 0
	mob_size = MOB_SIZE_BIG
	var/list/huggers = list()
	var/threw_a_hugger = 0
	var/eggs_cur = 0
	var/used_spawn_facehugger = FALSE
	var/last_spawn_facehugger
	var/cooldown_spawn_facehugger = 100 //10 seconds; keeping this as a var for now as I may have it adjust with upgrade level
	tier = XENO_TIER_TWO
	upgrade = XENO_UPGRADE_ZERO
	pixel_x = -16 //Needed for 2x2
	old_x = -16

	actions = list(
		/datum/action/xeno_action/xeno_resting,
		/datum/action/xeno_action/regurgitate,
		/datum/action/xeno_action/plant_weeds,
		/datum/action/xeno_action/activable/throw_hugger,
		/datum/action/xeno_action/activable/retrieve_egg,
		/datum/action/xeno_action/place_trap,
		/datum/action/xeno_action/spawn_hugger,
		/datum/action/xeno_action/toggle_pheromones
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)

/mob/living/carbon/Xenomorph/Carrier/death(gibbed)
	. = ..()
	if(. && !gibbed && length(huggers))
		var/chance = 75
		visible_message("<span class='xenowarning'>The chittering mass of tiny aliens is trying to escape [src]!</span>")
		for(var/i in 1 to 3)
			var/obj/item/clothing/mask/facehugger/F = pick_n_take(huggers)
			if(!F)
				return
			if(prob(chance))
				F.forceMove(loc)
				step_away(F,src,1)
				addtimer(CALLBACK(F, /obj/item/clothing/mask/facehugger.proc/GoActive, TRUE), 2 SECONDS)
			else
				qdel(F)
			chance -= 30
		QDEL_LIST(huggers)

/mob/living/carbon/Xenomorph/Carrier/Stat()
	. = ..()

	if(statpanel("Stats"))
		stat(null, "Stored Huggers: [huggers.len] / [xeno_caste.huggers_max]")
		stat(null, "Stored Eggs: [eggs_cur] / [xeno_caste.eggs_max]")


/mob/living/carbon/Xenomorph/Carrier/proc/store_hugger(obj/item/clothing/mask/facehugger/F, message = TRUE, forced = FALSE)
	if(huggers.len < xeno_caste.huggers_max)
		if(F.stat == CONSCIOUS || forced)
			transferItemToLoc(F, src)
			if(!F.stasis)
				F.GoIdle(TRUE)
			huggers.Add(F)
			if(message)
				to_chat(src, "<span class='notice'>You store the facehugger and carry it for safekeeping. Now sheltering: [huggers.len] / [xeno_caste.huggers_max].</span>")
		else if(message)
			to_chat(src, "<span class='warning'>This [F.name] looks too unhealthy.</span>")
	else if(message)
		to_chat(src, "<span class='warning'>You can't carry more facehuggers on you.</span>")


/mob/living/carbon/Xenomorph/Carrier/proc/throw_hugger(atom/T)
	if(!T)
		return

	if(!check_state())
		return

	//target a hugger on the ground to store it directly
	if(istype(T, /obj/item/clothing/mask/facehugger))
		var/obj/item/clothing/mask/facehugger/F = T
		if(isturf(F.loc) && Adjacent(F))
			if(!issamexenohive(F))
				to_chat(src, "<span class='warning'>That facehugger is tainted!</span>")
				dropItemToGround(F)
				return
			store_hugger(F)
			return

	var/obj/item/clothing/mask/facehugger/F = get_active_held_item()
	if(!F) //empty active hand
		//if no hugger in active hand, we take one from our storage
		if(!length(huggers))
			to_chat(src, "<span class='warning'>You don't have any facehuggers to use!</span>")
			return
		F = pick_n_take(huggers)
		put_in_active_hand(F)
		F.GoActive(TRUE)
		to_chat(src, "<span class='xenonotice'>You grab one of the facehugger in your storage. Now sheltering: [huggers.len] / [xeno_caste.huggers_max].</span>")
		return

	if(!istype(F)) //something else in our hand
		to_chat(src, "<span class='warning'>You need a facehugger in your hand to throw one!</span>")
		return

	if(!threw_a_hugger)
		threw_a_hugger = TRUE
		update_action_button_icons()
		dropItemToGround(F)
		F.throw_at(T, CARRIER_HUGGER_THROW_DISTANCE, CARRIER_HUGGER_THROW_SPEED)
		visible_message("<span class='xenowarning'>\The [src] throws something towards \the [T]!</span>", \
		"<span class='xenowarning'>You throw a facehugger towards \the [T]!</span>")
		addtimer(CALLBACK(src, .hugger_throw_cooldown), xeno_caste.hugger_delay)

/mob/living/carbon/Xenomorph/Carrier/proc/hugger_throw_cooldown()
	threw_a_hugger = FALSE
	update_action_button_icons()

/mob/living/carbon/Xenomorph/Carrier/proc/store_egg(obj/item/xeno_egg/E)
	if(!issamexenohive(E))
		to_chat(src, "<span class='warning'>That egg is tainted!</span>")
		return
	if(eggs_cur >= xeno_caste.eggs_max)
		to_chat(src, "<span class='warning'>You can't carry more eggs on you.</span>")
		return
	eggs_cur++
	to_chat(src, "<span class='notice'>You store the egg and carry it for safekeeping. Now sheltering: [eggs_cur] / [xeno_caste.eggs_max].</span>")
	qdel(E)

/mob/living/carbon/Xenomorph/Carrier/proc/retrieve_egg(atom/T)
	if(!T)
		return

	if(!check_state())
		return

	//target a hugger on the ground to store it directly
	if(istype(T, /obj/item/xeno_egg))
		var/obj/item/xeno_egg/E = T
		if(isturf(E.loc) && Adjacent(E))
			store_egg(E)
			return

	var/obj/item/xeno_egg/E = get_active_held_item()
	if(!E) //empty active hand
		//if no hugger in active hand, we take one from our storage
		if(eggs_cur <= 0)
			to_chat(src, "<span class='warning'>You don't have any egg to use!</span>")
			return
		E = new()
		E.hivenumber = hivenumber
		eggs_cur--
		put_in_active_hand(E)
		to_chat(src, "<span class='xenonotice'>You grab one of the eggs in your storage. Now sheltering: [eggs_cur] / [xeno_caste.eggs_max].</span>")
		return

	if(!istype(E)) //something else in our hand
		to_chat(src, "<span class='warning'>You need an empty hand to grab one of your stored eggs!</span>")
		return
