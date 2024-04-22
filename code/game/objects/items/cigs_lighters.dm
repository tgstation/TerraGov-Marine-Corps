//cleansed 9/15/2012 17:48

/*
CONTAINS:
MATCHEStype_butt
CIGARETTES
CIGARS
SMOKING PIPES
CHEAP LIGHTERS
ZIPPO

CIGARETTE PACKETS ARE IN FANCY.DM
*/

///////////
//MATCHES//
///////////
/obj/item/match
	name = "match"
	desc = ""
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "match_unlit"
	var/lit = FALSE
	var/burnt = FALSE
	var/smoketime = 15 // 10 seconds
	w_class = WEIGHT_CLASS_TINY
	heat = 1000
	grind_results = list(/datum/reagent/phosphorus = 2)

/obj/item/match/process()
	smoketime--
	if(smoketime < 1)
		matchburnout()
	else
		open_flame(heat)

/obj/item/match/fire_act(added, maxstacks)
	matchignite()

/obj/item/match/spark_act()
	fire_act()

/obj/item/match/proc/matchignite()
	if(!lit && !burnt)
		testing("ignis1")
		playsound(src, "sound/items/match.ogg", 100, FALSE)
		lit = TRUE
		icon_state = "match_lit"
		testing("ignis2")
		damtype = "fire"
		force = 3
		set_light(3)
		hitsound = list('sound/blank.ogg')
		name = "lit [initial(name)]"
		desc = ""
		attack_verb = list("burnt","singed")
		START_PROCESSING(SSobj, src)

/obj/item/match/proc/matchburnout()
	if(lit)
		lit = FALSE
		burnt = TRUE
		set_light(0)
		damtype = "brute"
		force = initial(force)
		icon_state = "match_burnt"
		item_state = "cigoff"
		name = "burnt [initial(name)]"
		desc = ""
		attack_verb = list("flicked")
		STOP_PROCESSING(SSobj, src)

/obj/item/match/extinguish()
	matchburnout()

/obj/item/match/dropped(mob/user)
	matchburnout()
	. = ..()

/obj/item/match/afterattack(atom/movable/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(lit && !burnt)
		A.spark_act()

/obj/item/match/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!isliving(M))
		return
//	if(lit && M.IgniteMob())
//		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
//		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && user.used_intent.type == INTENT_HELP)
		if(cig.lit)
			to_chat(user, "<span class='warning'>[cig] is already lit!</span>")
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light("<span class='notice'>[user] holds [src] out for [M], and lights [cig].</span>")
	else
		..()

/obj/item/proc/help_light_cig(mob/living/M)
	var/mask_item = M.get_item_by_slot(SLOT_MOUTH)
	if(istype(mask_item, /obj/item/clothing/mask/cigarette))
		return mask_item

/obj/item/match/get_temperature()
	return lit * heat

/obj/item/match/firebrand
	name = "firebrand"
	desc = ""
	smoketime = 20 //40 seconds
	grind_results = list(/datum/reagent/carbon = 2)

/obj/item/match/firebrand/Initialize()
	. = ..()
	matchignite()

//////////////////
//FINE SMOKABLES//
//////////////////
/obj/item/clothing/mask/cigarette
	name = "cigarette"
	desc = ""
	icon_state = "cigoff"
	throw_speed = 0.5
	item_state = "cigoff"
	w_class = WEIGHT_CLASS_TINY
	body_parts_covered = null
	grind_results = list()
	slot_flags = ITEM_SLOT_MOUTH
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/mouth_items.dmi'
	icon = 'icons/roguetown/items/lighting.dmi'
	heat = 1000
	spitoutmouth = FALSE
	var/dragtime = 100
	var/nextdragtime = 0
	var/lit = FALSE
	var/starts_lit = FALSE
	var/icon_on = "cigon"  //Note - these are in masks.dmi not in cigarette.dmi
	var/icon_off = "cigoff"
	var/type_butt = /obj/item/cigbutt
	var/lastHolder = null
	var/smoketime = 180 // 1 is 2 seconds, so a single cigarette will last 6 minutes.
	var/chem_volume = 30
	var/smoke_all = TRUE /// Should we smoke all of the chems in the cig before it runs out. Splits each puff to take a portion of the overall chems so by the end you'll always have consumed all of the chems inside.
	var/list/list_reagents = list(/datum/reagent/drug/nicotine = 15)

/obj/item/clothing/mask/cigarette/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is huffing [src] as quickly as [user.p_they()] can! It looks like [user.p_theyre()] trying to give [user.p_them()]self cancer.</span>")
	return (TOXLOSS|OXYLOSS)

/obj/item/clothing/mask/cigarette/Initialize()
	. = ..()
	create_reagents(chem_volume, INJECTABLE | NO_REACT)
	if(list_reagents)
		reagents.add_reagent_list(list_reagents)
	if(starts_lit)
		light()
	AddComponent(/datum/component/knockoff,90,list(BODY_ZONE_PRECISE_MOUTH),list(SLOT_MOUTH))//90% to knock off when wearing a mask

/obj/item/clothing/mask/cigarette/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/mask/cigarette/attackby(obj/item/W, mob/user, params)
	if(!lit && smoketime > 0)
		var/lighting_text = W.ignition_effect(src, user)
		if(lighting_text)
			light(lighting_text)
	else
		return ..()

/obj/item/clothing/mask/cigarette/afterattack(obj/item/reagent_containers/glass/glass, mob/user, proximity)
	. = ..()
//	if(!proximity || lit) //can't dip if cigarette is lit (it will heat the reagents in the glass instead)
//		return
//	if(istype(glass))	//you can dip cigarettes into beakers
//		if(glass.reagents.trans_to(src, chem_volume, transfered_by = user))	//if reagents were transfered, show the message
//			to_chat(user, "<span class='notice'>I dip \the [src] into \the [glass].</span>")
//		else			//if not, either the beaker was empty, or the cigarette was full
//			if(!glass.reagents.total_volume)
//				to_chat(user, "<span class='warning'>[glass] is empty!</span>")
//			else
//				to_chat(user, "<span class='warning'>[src] is full!</span>")


/obj/item/clothing/mask/cigarette/proc/light(flavor_text = null)
	if(lit)
		return
	if(smoketime <= 0)
		return
	if(!(flags_1 & INITIALIZED_1))
		icon_state = icon_on
		item_state = icon_on
		return

	lit = TRUE
//	name = "lit [name]"
	attack_verb = list("burnt", "singed")
	hitsound = list('sound/blank.ogg')
	damtype = "fire"
	force = 4
	if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)) // the plasma explodes when exposed to fire
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/plasma) / 2.5, 1), get_turf(src), 0, 0)
		e.start()
		qdel(src)
		return
	if(reagents.get_reagent_amount(/datum/reagent/fuel)) // the fuel explodes, too, but much less violently
		var/datum/effect_system/reagents_explosion/e = new()
		e.set_up(round(reagents.get_reagent_amount(/datum/reagent/fuel) / 5, 1), get_turf(src), 0, 0)
		e.start()
		qdel(src)
		return
	// allowing reagents to react after being lit
	DISABLE_BITFIELD(reagents.flags, NO_REACT)
	reagents.handle_reactions()
	icon_state = icon_on
	item_state = icon_on
	if(flavor_text)
		var/turf/T = get_turf(src)
		T.visible_message(flavor_text)
	START_PROCESSING(SSobj, src)

	//can't think of any other way to update the overlays :<
	if(ismob(loc))
		var/mob/M = loc
		M.update_inv_mouth()
		M.update_inv_hands()
		playsound(loc, 'sound/items/light_cig.ogg', 100, TRUE)

/obj/item/clothing/mask/cigarette/extinguish()
	if(!lit)
		return
	name = copytext(name,5,length(name)+1)
	attack_verb = null
	hitsound = null
	damtype = BRUTE
	force = 0
	icon_state = icon_off
	item_state = icon_off
	STOP_PROCESSING(SSobj, src)
	ENABLE_BITFIELD(reagents.flags, NO_REACT)
	lit = FALSE
	if(ismob(loc))
		var/mob/living/M = loc
		to_chat(M, "<span class='notice'>My [name] goes out.</span>")
		M.update_inv_mouth()
		M.update_inv_hands()

/obj/item/clothing/mask/cigarette/proc/handle_reagents()
	if(reagents.total_volume)
		var/to_smoke = REAGENTS_METABOLISM
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if (src == C.mouth) // if it's in the human/monkey mouth, transfer reagents to the mob
				var/fraction = min(REAGENTS_METABOLISM/reagents.total_volume, 1)
				/*
				 * Given the amount of time the cig will last, and how often we take a hit, find the number
				 * of chems to give them each time so they'll have smoked it all by the end.
				 */
				if (smoke_all)
					if(!smoketime)
						to_smoke = reagents.total_volume
					else
						to_smoke = reagents.total_volume/smoketime

				reagents.reaction(C, INGEST, fraction)
				if(!reagents.trans_to(C, to_smoke))
					reagents.remove_any(to_smoke)
				return
		reagents.remove_any(to_smoke)

/obj/item/clothing/mask/cigarette/process()
	var/turf/location = get_turf(src)
//	if(isliving(loc))
//		M.IgniteMob()
	smoketime--
	if(smoketime < 1)
		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			M.dropItemToGround(src, silent = TRUE)
			M.mouth = new type_butt(M)
		else
			new type_butt(location)
		qdel(src)
		return
	open_flame()
	if((reagents && reagents.total_volume) && (nextdragtime <= world.time))
		nextdragtime = world.time + dragtime
		handle_reagents()

/obj/item/clothing/mask/cigarette/attack_self(mob/user)
	if(lit)
		user.visible_message("<span class='notice'>[user] calmly drops and treads on \the [src], putting it out instantly.</span>")
		new type_butt(user.loc)
		new /obj/item/ash(user.loc)
		qdel(src)
	. = ..()

/obj/item/clothing/mask/cigarette/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()
	if(M.on_fire && !lit)
		light("<span class='notice'>[user] lights [src] with [M]'s burning body. What a cold-blooded badass.</span>")
		return
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && user.used_intent.type == INTENT_HELP)
		if(cig.lit)
			to_chat(user, "<span class='warning'>The [cig.name] is already lit!</span>")
		if(M == user)
			cig.attackby(src, user)
		else
			cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights [M.p_their()] [cig.name].</span>")
	else
		return ..()

/obj/item/clothing/mask/cigarette/fire_act(added, maxstacks)
	light()

/obj/item/clothing/mask/cigarette/spark_act()
	fire_act()

/obj/item/clothing/mask/cigarette/get_temperature()
	return lit * heat

// Cigarette brands.

/obj/item/clothing/mask/cigarette/space_cigarette
	desc = ""

/obj/item/clothing/mask/cigarette/dromedary
	desc = ""
	list_reagents = list(/datum/reagent/drug/nicotine = 13, /datum/reagent/water = 5) //camel has water

/obj/item/clothing/mask/cigarette/uplift
	desc = ""
	list_reagents = list(/datum/reagent/drug/nicotine = 13, /datum/reagent/consumable/menthol = 5)

/obj/item/clothing/mask/cigarette/robust
	desc = ""

/obj/item/clothing/mask/cigarette/robustgold
	desc = ""
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/gold = 3) // Just enough to taste a hint of expensive metal.

/obj/item/clothing/mask/cigarette/carp
	desc = ""

/obj/item/clothing/mask/cigarette/carp/Initialize()
	. = ..()
	if(prob(5))
		list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/toxin/carpotoxin = 3) //they lied

/obj/item/clothing/mask/cigarette/syndicate
	desc = ""
	chem_volume = 60
	smoketime = 60
	smoke_all = TRUE
	list_reagents = list(/datum/reagent/drug/nicotine = 10, /datum/reagent/medicine/omnizine = 15)

/obj/item/clothing/mask/cigarette/shadyjims
	desc = ""
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/toxin/lipolicide = 4, /datum/reagent/ammonia = 2, /datum/reagent/toxin/plantbgone = 1, /datum/reagent/toxin = 1.5)

/obj/item/clothing/mask/cigarette/xeno
	desc = ""
	list_reagents = list (/datum/reagent/drug/nicotine = 20, /datum/reagent/medicine/regen_jelly = 15, /datum/reagent/drug/krokodil = 4)

// Rollies.

/obj/item/clothing/mask/cigarette/rollie
	name = "zig"
	desc = ""
	icon_state = "spliffoff"
	icon_on = "spliffon"
	icon_off = "spliffoff"
	type_butt = /obj/item/cigbutt/roach
	throw_speed = 0.5
	item_state = "spliffoff"
	smoketime = 120 // four minutes
	chem_volume = 50
	list_reagents = null
	muteinmouth = FALSE

/obj/item/clothing/mask/cigarette/rollie/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/clothing/mask/cigarette/rollie/nicotine
	list_reagents = list(/datum/reagent/drug/nicotine = 30)

/obj/item/clothing/mask/cigarette/rollie/trippy
	list_reagents = list(/datum/reagent/drug/nicotine = 15, /datum/reagent/drug/mushroomhallucinogen = 35)
	starts_lit = TRUE

/obj/item/clothing/mask/cigarette/rollie/cannabis
	list_reagents = list(/datum/reagent/drug/space_drugs = 30)

/obj/item/clothing/mask/cigarette/rollie/mindbreaker
	list_reagents = list(/datum/reagent/toxin/mindbreaker = 35, /datum/reagent/toxin/lipolicide = 15)

/obj/item/clothing/mask/cigarette/candy
	name = "Little Timmy's candy cigarette"
	desc = ""
	smoketime = 120
	icon_on = "candyon"
	icon_off = "candyoff" //make sure to add positional sprites in icons/obj/cigarettes.dmi if you add more.
	item_state = "candyoff"
	icon_state = "candyoff"
	type_butt = /obj/item/reagent_containers/food/snacks/candy_trash
	list_reagents = list(/datum/reagent/consumable/sugar = 10, /datum/reagent/consumable/caramel = 10)

/obj/item/clothing/mask/cigarette/candy/nicotine
	desc = ""
	type_butt = /obj/item/reagent_containers/food/snacks/candy_trash/nicotine
	list_reagents = list(/datum/reagent/consumable/sugar = 10, /datum/reagent/consumable/caramel = 10, /datum/reagent/drug/nicotine = 20) //oh no!
	smoke_all = TRUE //timmy's not getting out of this one

/obj/item/cigbutt/roach
	name = "roach"
	desc = ""
	icon_state = "roach"

/obj/item/cigbutt/roach/Initialize()
	. = ..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)


////////////
// CIGARS //
////////////
/obj/item/clothing/mask/cigarette/cigar
	name = "premium cigar"
	desc = ""
	icon_state = "cigaroff"
	icon_on = "cigaron"
	icon_off = "cigaroff" //make sure to add positional sprites in icons/obj/cigarettes.dmi if you add more.
	type_butt = /obj/item/cigbutt/cigarbutt
	throw_speed = 0.5
	item_state = "cigaroff"
	smoketime = 300 // 11 minutes
	chem_volume = 40
	list_reagents = list(/datum/reagent/drug/nicotine = 25)

/obj/item/clothing/mask/cigarette/cigar/cohiba
	name = "\improper Cohiba Robusto cigar"
	desc = ""
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 600 // 20 minutes
	chem_volume = 80
	list_reagents =list(/datum/reagent/drug/nicotine = 40)

/obj/item/clothing/mask/cigarette/cigar/havana
	name = "premium Havanian cigar"
	desc = ""
	icon_state = "cigar2off"
	icon_on = "cigar2on"
	icon_off = "cigar2off"
	smoketime = 900 // 30 minutes
	chem_volume = 50
	list_reagents =list(/datum/reagent/drug/nicotine = 15)

/obj/item/cigbutt
	name = "cigarette butt"
	desc = ""
	icon = 'icons/roguetown/items/lighting.dmi'
	icon_state = "cigbutt"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	grind_results = list(/datum/reagent/carbon = 2)
	slot_flags = ITEM_SLOT_MOUTH
	spitoutmouth = TRUE


/obj/item/cigbutt/cigarbutt
	name = "cigar butt"
	desc = ""
	icon_state = "cigarbutt"

/////////////////
//SMOKING PIPES//
/////////////////
/obj/item/clothing/mask/cigarette/pipe
	name = "pipe"
	desc = ""
	icon_state = "pipeoff"
	item_state = "pipeoff"
	icon_on = "pipeon"  //Note - these are in masks.dmi
	icon_off = "pipeoff"
	smoketime = 120
	chem_volume = 100
	list_reagents = null
	var/packeditem = 0
	slot_flags = ITEM_SLOT_MOUTH
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/mouth_items.dmi'
	icon = 'icons/roguetown/items/lighting.dmi'
	muteinmouth = FALSE

/obj/item/clothing/mask/cigarette/pipe/westman
	name = "westman pipe"
	desc = ""
	icon_state = "longpipeoff"
	item_state = "longpipeoff"
	icon_on = "longpipeon"  //Note - these are in masks.dmi
	icon_off = "longpipeoff"

/obj/item/clothing/mask/cigarette/pipe/crafted/Initialize()
	. = ..()
	if(prob(50))
		name = "westman pipe"
		icon_state = "longpipeoff"
		item_state = "longpipeoff"
		icon_on = "longpipeon"
		icon_off = "longpipeoff"

/obj/item/clothing/mask/cigarette/pipe/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/clothing/mask/cigarette/pipe/process()
	if(smoketime <= 0 || !packeditem)
		packeditem = 0
		smoketime = 0
		STOP_PROCESSING(SSobj, src)
		return
	smoketime = max(smoketime -1, 0)
	if(smoketime <= 0)
		if(ismob(loc))
			var/mob/living/M = loc
			to_chat(M, "<span class='notice'>The [name] goes out.</span>")
			lit = 0
			icon_state = icon_off
			item_state = icon_off
			M.update_inv_mouth()
			packeditem = 0
//			name = "empty [initial(name)]"
		STOP_PROCESSING(SSobj, src)
		return
	open_flame()
	if(reagents && reagents.total_volume)	//	check if it has any reagents at all
		handle_reagents()


/obj/item/clothing/mask/cigarette/pipe/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/G = O
		if(!packeditem)
			if(G.dry == 1)
				to_chat(user, "<span class='notice'>I stuff [O] into [src].</span>")
				smoketime = initial(smoketime)
				packeditem = 1
//				name = "[O.name]-packed [initial(name)]"
				if(G.pipe_reagents?.len)
					reagents.add_reagent_list(G.pipe_reagents)
//					O.reagents.trans_to(src, O.reagents.total_volume, transfered_by = user)
				qdel(O)
			else
				to_chat(user, "<span class='warning'>It has to be dried first!</span>")
		else
			to_chat(user, "<span class='warning'>It is already packed!</span>")
	else if(istype(O, /obj/item/reagent_containers/powder/ozium))
		var/obj/item/reagent_containers/powder/ozium/G = O
		if(!packeditem)
			to_chat(user, "<span class='notice'>I stuff [O] into [src].</span>")
			smoketime = initial(smoketime)
			packeditem = 1
			if(G.list_reagents?.len)
				reagents.add_reagent_list(G.list_reagents)
			qdel(O)
		else
			to_chat(user, "<span class='warning'>It is already packed!</span>")
	else
		var/lighting_text = O.ignition_effect(src,user)
		if(lighting_text)
			if(smoketime > 0)
				light(lighting_text)
			else
				to_chat(user, "<span class='warning'>There is nothing to smoke!</span>")
		else
			return ..()

/obj/item/clothing/mask/cigarette/pipe/attack_self(mob/user)
	var/turf/location = get_turf(user)
	if(lit)
		user.visible_message("<span class='notice'>[user] puts out [src].</span>", "<span class='notice'>I put out [src].</span>")
		lit = 0
		icon_state = icon_off
		item_state = icon_off
		STOP_PROCESSING(SSobj, src)
		return
	if(!lit && smoketime > 0)
		smoketime = 0
		to_chat(user, "<span class='notice'>I empty [src] onto [location].</span>")
		new /obj/item/ash(location)
		packeditem = 0
		reagents.clear_reagents()
//		name = "empty [initial(name)]"
	return

/obj/item/clothing/mask/cigarette/pipe/cobpipe
	name = "corn cob pipe"
	desc = ""
	icon_state = "cobpipeoff"
	item_state = "cobpipeoff"
	icon_on = "cobpipeon"  //Note - these are in masks.dmi
	icon_off = "cobpipeoff"
	smoketime = 0


/////////
//ZIPPO//
/////////
/obj/item/lighter
	name = "\improper Zippo lighter"
	desc = ""
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "zippo"
	item_state = "zippo"
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT

	var/lit = 0
	var/fancy = TRUE
	var/overlay_state
	var/overlay_list = list(
		"plain",
		"dame",
		"thirteen",
		"snake"
		)
	heat = 1500
	resistance_flags = FIRE_PROOF
	light_color = LIGHT_COLOR_FIRE
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.6
	grind_results = list(/datum/reagent/iron = 1, /datum/reagent/fuel = 5, /datum/reagent/fuel/oil = 5)

/obj/item/lighter/Initialize()
	. = ..()
	if(!overlay_state)
		overlay_state = pick(overlay_list)
	update_icon()

/obj/item/lighter/cyborg_unequip(mob/user)
	if(!lit)
		return
	set_lit(FALSE)

/obj/item/lighter/suicide_act(mob/living/carbon/user)
	if (lit)
		user.visible_message("<span class='suicide'>[user] begins holding \the [src]'s flame up to [user.p_their()] face! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		playsound(src, 'sound/blank.ogg', 50, TRUE)
		return FIRELOSS
	else
		user.visible_message("<span class='suicide'>[user] begins whacking [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
		return BRUTELOSS

/obj/item/lighter/update_icon()
	cut_overlays()
	var/mutable_appearance/lighter_overlay = mutable_appearance(icon,"lighter_overlay_[overlay_state][lit ? "-on" : ""]")
	icon_state = "[initial(icon_state)][lit ? "-on" : ""]"
	add_overlay(lighter_overlay)

/obj/item/lighter/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		. = "<span class='rose'>With a single flick of [user.p_their()] wrist, [user] smoothly lights [A] with [src]. Damn [user.p_theyre()] cool.</span>"

/obj/item/lighter/proc/set_lit(new_lit)
	if(lit == new_lit)
		return
	lit = new_lit
	if(lit)
		force = 5
		damtype = "fire"
		hitsound = list('sound/blank.ogg')
		attack_verb = list("burnt", "singed")
		START_PROCESSING(SSobj, src)
	else
		hitsound = list("swing_hit")
		force = 0
		attack_verb = null //human_defense.dm takes care of it
		STOP_PROCESSING(SSobj, src)
	set_light_on(lit)
	update_icon()

/obj/item/lighter/extinguish()
	set_lit(FALSE)

/obj/item/lighter/attack_self(mob/living/user)
	if(user.is_holding(src))
		if(!lit)
			set_lit(TRUE)
			if(fancy)
				user.visible_message("<span class='notice'>Without even breaking stride, [user] flips open and lights [src] in one smooth movement.</span>", "<span class='notice'>Without even breaking stride, you flip open and light [src] in one smooth movement.</span>")
			else
				var/prot = FALSE
				var/mob/living/carbon/human/H = user

				if(istype(H) && H.gloves)
					var/obj/item/clothing/gloves/G = H.gloves
					if(G.max_heat_protection_temperature)
						prot = (G.max_heat_protection_temperature > 360)
				else
					prot = TRUE

				if(prot || prob(75))
					user.visible_message("<span class='notice'>After a few attempts, [user] manages to light [src].</span>", "<span class='notice'>After a few attempts, you manage to light [src].</span>")
				else
					var/hitzone = user.held_index_to_dir(user.active_hand_index) == "r" ? BODY_ZONE_PRECISE_R_HAND : BODY_ZONE_PRECISE_L_HAND
					user.apply_damage(5, BURN, hitzone)
					user.visible_message("<span class='warning'>After a few attempts, [user] manages to light [src] - however, [user.p_they()] burn [user.p_their()] finger in the process.</span>", "<span class='warning'>I burn myself while lighting the lighter!</span>")
					SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "burnt_thumb", /datum/mood_event/burnt_thumb)

		else
			set_lit(FALSE)
			if(fancy)
				user.visible_message("<span class='notice'>I hear a quiet click, as [user] shuts off [src] without even looking at what [user.p_theyre()] doing. Wow.</span>", "<span class='notice'>I quietly shut off [src] without even looking at what you're doing. Wow.</span>")
			else
				user.visible_message("<span class='notice'>[user] quietly shuts off [src].</span>", "<span class='notice'>I quietly shut off [src].</span>")
	else
		. = ..()

/obj/item/lighter/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(lit && M.IgniteMob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && user.used_intent.type == INTENT_HELP)
		if(cig.lit)
			to_chat(user, "<span class='warning'>The [cig.name] is already lit!</span>")
		if(M == user)
			cig.attackby(src, user)
		else
			if(fancy)
				cig.light("<span class='rose'>[user] whips the [name] out and holds it for [M]. [user.p_their(TRUE)] arm is as steady as the unflickering flame [user.p_they()] light[user.p_s()] \the [cig] with.</span>")
			else
				cig.light("<span class='notice'>[user] holds the [name] out for [M], and lights [M.p_their()] [cig.name].</span>")
	else
		..()

/obj/item/lighter/process()
	open_flame()

/obj/item/lighter/get_temperature()
	return lit * heat


/obj/item/lighter/greyscale
	name = "cheap lighter"
	desc = ""
	icon_state = "lighter"
	fancy = FALSE
	overlay_list = list(
		"transp",
		"tall",
		"matte",
		"zoppo" //u cant stoppo th zoppo
		)
	var/lighter_color
	var/list/color_list = list( //Same 16 color selection as electronic assemblies
		COLOR_ASSEMBLY_BLACK,
		COLOR_FLOORTILE_GRAY,
		COLOR_ASSEMBLY_BGRAY,
		COLOR_ASSEMBLY_WHITE,
		COLOR_ASSEMBLY_RED,
		COLOR_ASSEMBLY_ORANGE,
		COLOR_ASSEMBLY_BEIGE,
		COLOR_ASSEMBLY_BROWN,
		COLOR_ASSEMBLY_GOLD,
		COLOR_ASSEMBLY_YELLOW,
		COLOR_ASSEMBLY_GURKHA,
		COLOR_ASSEMBLY_LGREEN,
		COLOR_ASSEMBLY_GREEN,
		COLOR_ASSEMBLY_LBLUE,
		COLOR_ASSEMBLY_BLUE,
		COLOR_ASSEMBLY_PURPLE
		)

/obj/item/lighter/greyscale/Initialize()
	. = ..()
	if(!lighter_color)
		lighter_color = pick(color_list)
	update_icon()

/obj/item/lighter/greyscale/update_icon()
	cut_overlays()
	var/mutable_appearance/lighter_overlay = mutable_appearance(icon,"lighter_overlay_[overlay_state][lit ? "-on" : ""]")
	icon_state = "[initial(icon_state)][lit ? "-on" : ""]"
	lighter_overlay.color = lighter_color
	add_overlay(lighter_overlay)

/obj/item/lighter/greyscale/ignition_effect(atom/A, mob/user)
	if(get_temperature())
		. = "<span class='notice'>After some fiddling, [user] manages to light [A] with [src].</span>"


/obj/item/lighter/slime
	name = "slime zippo"
	desc = ""
	icon_state = "slighter"
	heat = 3000 //Blue flame!
	light_color = LIGHT_COLOR_CYAN
	overlay_state = "slime"
	grind_results = list(/datum/reagent/iron = 1, /datum/reagent/fuel = 5, /datum/reagent/medicine/pyroxadone = 5)


///////////
//ROLLING//
///////////
/obj/item/rollingpaper
	name = "rolling paper"
	desc = ""
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper"
	w_class = WEIGHT_CLASS_TINY

/obj/item/rollingpaper/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/item/reagent_containers/food/snacks/grown))
		var/obj/item/reagent_containers/food/snacks/grown/O = target
		if(O.dry)
			var/obj/item/clothing/mask/cigarette/rollie/R = new /obj/item/clothing/mask/cigarette/rollie(user.loc)
			R.chem_volume = target.reagents.total_volume
			target.reagents.trans_to(R, R.chem_volume, transfered_by = user)
			qdel(target)
			qdel(src)
			user.put_in_active_hand(R)
			to_chat(user, "<span class='notice'>I roll the [target.name] into a rolling paper.</span>")
			R.desc = ""
		else
			to_chat(user, "<span class='warning'>I need to dry this first!</span>")

///////////////
//VAPE NATION//
///////////////
/obj/item/clothing/mask/vape
	name = "\improper E-Cigarette"
	desc = ""//<<< i'd vape to that.
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "red_vape"
	item_state = null
	w_class = WEIGHT_CLASS_TINY
	var/chem_volume = 100
	var/vapetime = 0 //this so it won't puff out clouds every tick
	var/screw = 0 // kinky
	var/super = 0 //for the fattest vapes dude.

/obj/item/clothing/mask/vape/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is puffin hard on dat vape, [user.p_they()] trying to join the vape life on a whole notha plane!</span>")//it doesn't give you cancer, it is cancer
	return (TOXLOSS|OXYLOSS)


/obj/item/clothing/mask/vape/Initialize(mapload, param_color)
	. = ..()
	create_reagents(chem_volume, NO_REACT)
	reagents.add_reagent(/datum/reagent/drug/nicotine, 50)
	if(!param_color)
		param_color = pick("red","blue","black","white","green","purple","yellow","orange")
	icon_state = "[param_color]_vape"
	item_state = "[param_color]_vape"

/obj/item/clothing/mask/vape/attackby(obj/item/O, mob/user, params)
	if(O.tool_behaviour == TOOL_SCREWDRIVER)
		if(!screw)
			screw = TRUE
			to_chat(user, "<span class='notice'>I open the cap on [src].</span>")
			ENABLE_BITFIELD(reagents.flags, OPENCONTAINER)
			if(obj_flags & EMAGGED)
				add_overlay("vapeopen_high")
			else if(super)
				add_overlay("vapeopen_med")
			else
				add_overlay("vapeopen_low")
		else
			screw = FALSE
			to_chat(user, "<span class='notice'>I close the cap on [src].</span>")
			DISABLE_BITFIELD(reagents.flags, OPENCONTAINER)
			cut_overlays()

	if(O.tool_behaviour == TOOL_MULTITOOL)
		if(screw && !(obj_flags & EMAGGED))//also kinky
			if(!super)
				cut_overlays()
				super = 1
				to_chat(user, "<span class='notice'>I increase the voltage of [src].</span>")
				add_overlay("vapeopen_med")
			else
				cut_overlays()
				super = 0
				to_chat(user, "<span class='notice'>I decrease the voltage of [src].</span>")
				add_overlay("vapeopen_low")

		if(screw && (obj_flags & EMAGGED))
			to_chat(user, "<span class='warning'>[src] can't be modified!</span>")
		else
			..()


/obj/item/clothing/mask/vape/emag_act(mob/user)// I WON'T REGRET WRITTING THIS, SURLY.
	if(screw)
		if(!(obj_flags & EMAGGED))
			cut_overlays()
			obj_flags |= EMAGGED
			super = 0
			to_chat(user, "<span class='warning'>I maximize the voltage of [src].</span>")
			add_overlay("vapeopen_high")
			var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread //for effect
			sp.set_up(5, 1, src)
			sp.start()
		else
			to_chat(user, "<span class='warning'>[src] is already emagged!</span>")
	else
		to_chat(user, "<span class='warning'>I need to open the cap to do that!</span>")

/obj/item/clothing/mask/vape/attack_self(mob/user)
	if(reagents.total_volume > 0)
		to_chat(user, "<span class='notice'>I empty [src] of all reagents.</span>")
		reagents.clear_reagents()

/obj/item/clothing/mask/vape/equipped(mob/user, slot)
	. = ..()
	if(slot == SLOT_WEAR_MASK)
		if(!screw)
			to_chat(user, "<span class='notice'>I start puffing on the vape.</span>")
			DISABLE_BITFIELD(reagents.flags, NO_REACT)
			START_PROCESSING(SSobj, src)
		else //it will not start if the vape is opened.
			to_chat(user, "<span class='warning'>I need to close the cap first!</span>")

/obj/item/clothing/mask/vape/dropped(mob/user)
	. = ..()
	if(user.get_item_by_slot(SLOT_WEAR_MASK) == src)
		ENABLE_BITFIELD(reagents.flags, NO_REACT)
		STOP_PROCESSING(SSobj, src)

/obj/item/clothing/mask/vape/proc/hand_reagents()//had to rename to avoid duplicate error
	if(reagents.total_volume)
		if(iscarbon(loc))
			var/mob/living/carbon/C = loc
			if (src == C.wear_mask) // if it's in the human/monkey mouth, transfer reagents to the mob
				var/fraction = min(REAGENTS_METABOLISM/reagents.total_volume, 1) //this will react instantly, making them a little more dangerous than cigarettes
				reagents.reaction(C, INGEST, fraction)
				if(!reagents.trans_to(C, REAGENTS_METABOLISM))
					reagents.remove_any(REAGENTS_METABOLISM)
				if(reagents.get_reagent_amount(/datum/reagent/fuel))
					//HOT STUFF
					C.fire_stacks = 2
					C.IgniteMob()

				if(reagents.get_reagent_amount(/datum/reagent/toxin/plasma)) // the plasma explodes when exposed to fire
					var/datum/effect_system/reagents_explosion/e = new()
					e.set_up(round(reagents.get_reagent_amount(/datum/reagent/toxin/plasma) / 2.5, 1), get_turf(src), 0, 0)
					e.start()
					qdel(src)
				return
		reagents.remove_any(REAGENTS_METABOLISM)

/obj/item/clothing/mask/vape/process()
	var/mob/living/M = loc

	if(isliving(loc))
		M.IgniteMob()

	vapetime++

	if(!reagents.total_volume)
		if(ismob(loc))
			to_chat(M, "<span class='warning'>[src] is empty!</span>")
			STOP_PROCESSING(SSobj, src)
			//it's reusable so it won't unequip when empty
		return
	//open flame removed because vapes are a closed system, they wont light anything on fire

	if(super && vapetime > 3)//Time to start puffing those fat vapes, yo.
		var/datum/effect_system/smoke_spread/chem/smoke_machine/s = new
		s.set_up(reagents, 1, 24, loc)
		s.start()
		vapetime = 0

	if((obj_flags & EMAGGED) && vapetime > 3)
		var/datum/effect_system/smoke_spread/chem/smoke_machine/s = new
		s.set_up(reagents, 4, 24, loc)
		s.start()
		vapetime = 0
		if(prob(5))//small chance for the vape to break and deal damage if it's emagged
			playsound(get_turf(src), 'sound/blank.ogg', 50, FALSE)
			M.apply_damage(20, BURN, BODY_ZONE_HEAD)
			M.Paralyze(300, 1, 0)
			var/datum/effect_system/spark_spread/sp = new /datum/effect_system/spark_spread
			sp.set_up(5, 1, src)
			sp.start()
			to_chat(M, "<span class='danger'>[src] suddenly explodes in my mouth!</span>")
			qdel(src)
			return

	if(reagents && reagents.total_volume)
		hand_reagents()
