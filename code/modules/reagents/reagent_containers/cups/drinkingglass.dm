/obj/item/reagent_containers/cup/glass/drinkingglass
	name = "drinking glass"
	desc = "Your standard drinking glass."
	icon_state = "glass_empty"
	base_icon_state = "glass_empty"
	amount_per_transfer_from_this = 10
	fill_icon_thresholds = list(0)
	fill_icon_state = "drinking_glass"
	volume = 50
	max_integrity = 20
	resistance_flags = UNACIDABLE
	//the screwdriver cocktail can make a drinking glass into the world's worst screwdriver. beautiful.
	toolspeed = 25

	/// The type to compare to glass_style.required_container type, or null to use class type.
	/// This allows subtypes to utilize parent styles.
	var/base_container_type = null

/obj/item/reagent_containers/cup/glass/drinkingglass/Initialize(mapload, vol)
	. = ..()
	AddComponent( \
		/datum/component/takes_reagent_appearance, \
		CALLBACK(src, PROC_REF(on_cup_change)), \
		CALLBACK(src, PROC_REF(on_cup_reset)), \
		base_container_type = base_container_type, \
	)
	RegisterSignal(src, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_cleaned))

// Having our icon state change removes fill thresholds
/obj/item/reagent_containers/cup/glass/drinkingglass/on_cup_change(datum/glass_style/style)
	. = ..()
	fill_icon_thresholds = null

// And having our icon reset restores our fill thresholds
/obj/item/reagent_containers/cup/glass/drinkingglass/on_cup_reset()
	. = ..()
	fill_icon_thresholds ||= list(0)

/obj/item/reagent_containers/cup/glass/drinkingglass/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_WAS_RENAMED))
		. += span_notice("This glass has been given a custom name. It can be removed by washing it.")

/obj/item/reagent_containers/cup/glass/drinkingglass/attack_alien(mob/living/carbon/xenomorph/xeno_attacker, damage_amount = xeno_attacker.xeno_caste.melee_damage, damage_type = BRUTE, armor_type = MELEE, effects = TRUE, armor_penetration = xeno_attacker.xeno_caste.melee_ap, isrightclick = FALSE)
	if(!CONFIG_GET(flag/fun_allowed))
		return FALSE
	attack_hand(xeno_attacker)

/obj/item/reagent_containers/cup/glass/drinkingglass/proc/on_cleaned(obj/source_component, obj/source)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(src, TRAIT_WAS_RENAMED))
		return

	name = initial(name)
	desc = initial(desc)
	update_appearance(UPDATE_NAME | UPDATE_DESC)

//Shot glasses!//
//  This lets us add shots in here instead of lumping them in with drinks because >logic  //
//  The format for shots is the exact same as iconstates for the drinking glass, except you use a shot glass instead.  //
//  If it's a new drink, remember to add it to Chemistry-Reagents.dm  and Chemistry-Recipes.dm as well.  //
//  You can only mix the ported-over drinks in shot glasses for now (they'll mix in a shaker, but the sprite won't change for glasses). //
//  This is on a case-by-case basis, and you can even make a separate sprite for shot glasses if you want. //

/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass
	name = "shot glass"
	desc = "A shot glass - the universal symbol for bad decisions."
	icon = 'icons/obj/drinks/shot_glasses.dmi'
	icon_state = "shotglass"
	base_icon_state = "shotglass"
	gulp_size = 15
	amount_per_transfer_from_this = 15
	possible_transfer_amounts = list(15)
	fill_icon_state = "shot_glass"
	volume = 15

/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass/update_name(updates)
	if(HAS_TRAIT(src, TRAIT_WAS_RENAMED))
		return
	. = ..()
	name = "[length(reagents.reagent_list) ? "filled " : ""]shot glass"

/obj/item/reagent_containers/cup/glass/drinkingglass/shotglass/update_desc(updates)
	if(HAS_TRAIT(src, TRAIT_WAS_RENAMED))
		return
	. = ..()
	if(length(reagents.reagent_list))
		desc = "The challenge is not taking as many as you can, but guessing what it is before you pass out."
	else
		desc = "A shot glass - the universal symbol for bad decisions."

/obj/item/reagent_containers/cup/glass/drinkingglass/filled
	base_container_type = /obj/item/reagent_containers/cup/glass/drinkingglass

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/Initialize(mapload, vol)
	. = ..()
	update_appearance()

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/soda
	name = "Soda Water"
	list_reagents = list(/datum/reagent/consumable/sodawater = 50)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/cola
	name = "Space Cola"
	list_reagents = list(/datum/reagent/consumable/space_cola = 50)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/nuka_cola
	name = "Nuka Cola"
	list_reagents = list(/datum/reagent/consumable/nuka_cola = 50)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/pina_colada
	name = "Pina Colada"
	list_reagents = list(/datum/reagent/consumable/ethanol/pina_colada = 50)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/half_full
	name = "half full glass of water"
	desc  = "It's a glass of water. It seems half full. Or is it half empty? You're pretty sure it's full of shit."
	list_reagents = list(/datum/reagent/water = 25)

/obj/item/reagent_containers/cup/glass/drinkingglass/filled/half_full/Initialize(mapload, vol)
	. = ..()
	name = "[pick("half full", "half empty")] glass of water"
