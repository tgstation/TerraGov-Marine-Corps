
//////////////////////////soda_cans//
//These are in their own group to be used as IED's in /obj/item/grenade/ghettobomb.dm
/// How much fizziness is added to the can of soda by throwing it, in percentage points
#define SODA_FIZZINESS_THROWN 15
/// How much fizziness is added to the can of soda by shaking it, in percentage points
#define SODA_FIZZINESS_SHAKE 5

/obj/item/reagent_containers/cup/soda_cans
	name = "soda can"
	icon = 'icons/obj/drinks/soda.dmi'
	icon_state = "cola"
	icon_state_preview = "cola"
	reagent_flags = NONE
	obj_flags = CAN_BE_HIT
	possible_transfer_amounts = list(5, 10, 15, 25, 30)
	volume = 30
	throwforce = 12 // set to 0 upon being opened. Have you ever been domed by a soda can? Those things fucking hurt
	/// If the can hasn't been opened yet, this is the measure of how fizzed up it is from being shaken or thrown around. When opened, this is rolled as a percentage chance to burst
	var/fizziness = 0

/obj/item/reagent_containers/cup/soda_cans/random/Initialize(mapload)
	..()
	var/T = pick(subtypesof(/obj/item/reagent_containers/cup/soda_cans) - /obj/item/reagent_containers/cup/soda_cans/random)
	new T(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/reagent_containers/cup/soda_cans/attack(mob/target_mob, mob/living/user)
	if(iscarbon(target_mob) && !reagents.total_volume && (user.a_intent == INTENT_HARM) && user.zone_selected == BODY_ZONE_HEAD)
		if(target_mob == user)
			user.visible_message(span_warning("[user] crushes the can of [src] on [user.p_their()] forehead!"), span_notice("You crush the can of [src] on your forehead."))
		else
			user.visible_message(span_warning("[user] crushes the can of [src] on [target_mob]'s forehead!"), span_notice("You crush the can of [src] on [target_mob]'s forehead."))
		playsound(target_mob,'sound/weapons/pierce.ogg', rand(10,50), TRUE)
		var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(target_mob.loc)
		crushed_can.icon_state = icon_state
		qdel(src)
		return TRUE
	return ..()

/obj/item/reagent_containers/cup/soda_cans/proc/open_soda(mob/user)
	if(prob(fizziness))
		user.visible_message(span_danger("[user] opens [src], and is suddenly sprayed by the fizzing contents!"), span_danger("You pull back the tab of [src], and are suddenly sprayed with a torrent of liquid! Ahhh!!"))
		burst_soda(user)
		return

	to_chat(user, "You pull back the tab of [src] with a satisfying pop.") //Ahhhhhhhh
	reagents.reagent_flags |= OPENCONTAINER
	playsound(src, "can_open", 50, TRUE)
	throwforce = 0

/**
 * Burst the soda open on someone. Fun! Opens and empties the soda can, but does not crush it.
 *
 * Arguments:
 * * target - Who's getting covered in soda
 * * hide_message - Stops the generic fizzing message, so you can do your own
 */
/obj/item/reagent_containers/cup/soda_cans/proc/burst_soda(atom/target, hide_message = FALSE)
	if(!target)
		return

	playsound(src, 'sound/effects/can_pop.ogg', 80, TRUE)
	if(!hide_message)
		visible_message(span_danger("[src] spills over, fizzing its contents all over [target]!"))
	reagents.reagent_flags |= OPENCONTAINER
	reagents.clear_reagents()
	throwforce = 0

/obj/item/reagent_containers/cup/soda_cans/throw_impact(atom/hit_atom, speed, bounce)
	. = ..()
	if(. || !reagents.total_volume) // if it was caught, already opened, or has nothing in it
		return

	fizziness += SODA_FIZZINESS_THROWN
	if(!prob(fizziness))
		return

	burst_soda(hit_atom, hide_message = TRUE)
	visible_message(span_danger("[src]'s impact with [hit_atom] causes it to rupture, spilling everywhere!"))
	var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(src.loc)
	crushed_can.icon_state = icon_state
	moveToNullspace()
	QDEL_IN(src, 1 SECONDS) // give it a second so it can still be logged for the throw impact

/obj/item/reagent_containers/cup/soda_cans/attack_self(mob/user)
	if(!is_drainable())
		open_soda(user)
		return
	return ..()

/obj/item/reagent_containers/cup/soda_cans/attack_self_alternate(mob/living/user)
	if(!is_drainable())
		playsound(src, 'sound/effects/can_shake.ogg', 50, TRUE)
		user.visible_message(span_danger("[user] shakes [src]!"), span_danger("You shake up [src]!"), vision_distance=2)
		fizziness += SODA_FIZZINESS_SHAKE
		return
	return ..()

/obj/item/reagent_containers/cup/soda_cans/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		return
	if(fizziness > 30 && prob(fizziness * 2))
		. += span_notice("<i>You examine [src] closer, and note the following...</i>")
		. += "\t[span_warning("You get a menacing aura of fizziness from it...")]"

#undef SODA_FIZZINESS_THROWN
#undef SODA_FIZZINESS_SHAKE

/obj/item/reagent_containers/cup/soda_cans/cola
	name = "Space Cola"
	desc = "Cola. in space."
	icon_state = "cola"
	list_reagents = list(/datum/reagent/consumable/space_cola = 30)
	drink_type = SUGAR

/obj/item/reagent_containers/cup/soda_cans/tonic
	name = "T-Borg's tonic water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	icon_state = "tonic"
	volume = 50
	list_reagents = list(/datum/reagent/consumable/tonic = 50)
	drink_type = ALCOHOL

/obj/item/reagent_containers/cup/soda_cans/sodawater
	name = "soda water"
	desc = "A can of soda water. Why not make a scotch and soda?"
	icon_state = "sodawater"
	volume = 50
	list_reagents = list(/datum/reagent/consumable/sodawater = 50)

/obj/item/reagent_containers/cup/soda_cans/lemon_lime
	name = "orange soda"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	icon_state = "lemon-lime"
	list_reagents = list(/datum/reagent/consumable/lemon_lime = 30)
	drink_type = FRUIT

/obj/item/reagent_containers/cup/soda_cans/lemon_lime/Initialize(mapload)
	. = ..()
	name = "lemon-lime soda"

/obj/item/reagent_containers/cup/soda_cans/sol_dry
	name = "Sol Dry"
	desc = "Maybe this will help your tummy feel better. Maybe not."
	icon_state = "sol_dry"
	list_reagents = list(/datum/reagent/consumable/sol_dry = 30)
	drink_type = SUGAR

/obj/item/reagent_containers/cup/soda_cans/space_up
	name = "Space-Up!"
	desc = "Tastes like a hull breach in your mouth."
	icon_state = "space-up"
	list_reagents = list(/datum/reagent/consumable/space_up = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/starkist
	name = "Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	icon_state = "starkist"
	list_reagents = list(/datum/reagent/consumable/space_cola = 15, /datum/reagent/consumable/orangejuice = 15)
	drink_type = SUGAR | FRUIT | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/space_mountain_wind
	name = "Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	icon_state = "space_mountain_wind"
	list_reagents = list(/datum/reagent/consumable/spacemountainwind = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/thirteenloko
	name = "Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, blindness, drunkenness, or even death. Please Drink Responsibly."
	icon_state = "thirteen_loko"
	list_reagents = list(/datum/reagent/consumable/ethanol/thirteenloko = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/dr_gibb
	name = "Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	icon_state = "dr_gibb"
	list_reagents = list(/datum/reagent/consumable/dr_gibb = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/pwr_game
	name = "Pwr Game"
	desc = "The only drink with the PWR that true gamers crave. When a gamer talks about gamerfuel, this is what they're literally referring to."
	icon_state = "purple_can"
	list_reagents = list(/datum/reagent/consumable/pwr_game = 30)

/obj/item/reagent_containers/cup/soda_cans/shamblers
	name = "Shambler's juice"
	desc = "~Shake me up some of that Shambler's Juice!~"
	icon_state = "shamblers"
	list_reagents = list(/datum/reagent/consumable/shamblers = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/wellcheers
	name = "Wellcheers Juice"
	desc = "A strange purple drink, smelling of saltwater. Somewhere in the distance, you hear seagulls."
	icon_state = "wellcheers"
	list_reagents = list(/datum/reagent/consumable/wellcheers = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/grey_bull
	name = "Grey Bull"
	desc = "Grey Bull, it gives you gloves!"
	icon_state = "energy_drink"
	list_reagents = list(/datum/reagent/consumable/grey_bull = 20)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/monkey_energy
	name = "Monkey Energy"
	desc = "Unleash the ape!"
	icon_state = "monkey_energy"
	volume = 50
	list_reagents = list(/datum/reagent/consumable/monkey_energy = 50)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/volt_energy
	name = "24-Volt Energy"
	desc = "Recharge, with 24-Volt Energy!"
	icon_state = "volt_energy"
	list_reagents = list(/datum/reagent/consumable/volt_energy = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/melon_soda
	name = "Kansumi Melon Soda"
	desc = "Japan's favourite melon soda, now available in can form!"
	icon_state = "melon_soda"
	list_reagents = list(/datum/reagent/consumable/melon_soda = 30)
	drink_type = SUGAR | JUNKFOOD

/obj/item/reagent_containers/cup/soda_cans/air
	name = "canned air"
	desc = "There is no air shortage. Do not drink."
	icon_state = "air"
	list_reagents = list(/datum/reagent/nitrogen = 24, /datum/reagent/oxygen = 6)

/obj/item/reagent_containers/cup/soda_cans/beer
	name = "space beer"
	desc = "Canned beer. In space."
	icon_state = "space_beer"
	volume = 40
	list_reagents = list(/datum/reagent/consumable/ethanol/beer = 40)
	drink_type = GRAIN

/obj/item/reagent_containers/cup/soda_cans/beer/rice
	name = "rice beer"
	desc = "A light, rice-based lagered beer popular on Mars. Considered a hate crime against Bavarians under the Reinheitsgebot Act of 1516."
	icon_state = "ebisu"
	list_reagents = list(/datum/reagent/consumable/ethanol/rice_beer = 40)

/obj/item/reagent_containers/cup/soda_cans/beer/rice/Initialize(mapload)
	. = ..()
	var/brand = pick("Ebisu Super Dry", "Shimauma Ichiban", "Moonlabor Malt's")
	name = "[brand]"
	switch(brand)
		if("Ebisu Super Dry")
			icon_state = "ebisu"
			desc = "Mars' favourite rice beer brand, 200 years running."
		if("Shimauma Ichiban")
			icon_state = "shimauma"
			desc = "Mars' most middling rice beer brand. Not as popular as Ebisu, but it's comfortable in second place."
		if("Moonlabor Malt's")
			icon_state = "moonlabor"
			desc = "Mars' underdog rice beer brand. Popular amongst the Yakuza, for reasons unknown."
