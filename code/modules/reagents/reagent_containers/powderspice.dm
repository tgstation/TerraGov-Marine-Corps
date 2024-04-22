/obj/item/reagent_containers/powder
	name = "spice"
	desc = ""
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "spice"
	item_state = "spice"
	possible_transfer_amounts = list()
	volume = 15
	list_reagents = list(/datum/reagent/druqks = 15)
	sellprice = 10

/datum/reagent/druqks
	name = "Drukqs"
	description = ""
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 16
	metabolization_rate = 0.2

/datum/reagent/druqks/overdose_process(mob/living/M)
	M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 0.25*REM)
	M.adjustToxLoss(0.25*REM, 0)
	..()
	. = 1

/datum/reagent/druqks/on_mob_life(mob/living/carbon/M)
	M.set_drugginess(30)
	if(prob(5))
		if(M.gender == FEMALE)
			M.emote(pick("twitch_s","giggle"))
		else
			M.emote(pick("twitch_s","chuckle"))
	if(M.has_flaw(/datum/charflaw/addiction/junkie))
		M.sate_addiction()
	M.apply_status_effect(/datum/status_effect/buff/druqks)
	..()

/obj/screen/fullscreen/druqks
	icon_state = "spa"
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	blend_mode = 0
	show_when_dead = FALSE

/datum/reagent/druqks/overdose_start(mob/living/M)
	M.visible_message("<span class='warning'>Blood runs from [M]'s nose.</span>")

/datum/reagent/druqks/overdose_process(mob/living/M)
	M.adjustToxLoss(10, 0)

/datum/reagent/druqks/on_mob_metabolize(mob/living/M)
	M.overlay_fullscreen("druqk", /obj/screen/fullscreen/druqks)
	M.set_drugginess(30)
	M.update_body_parts_head_only()
	if(M.client)
		ADD_TRAIT(M, TRAIT_DRUQK, "based")
		SSdroning.area_entered(get_area(M), M.client)
//			if(M.client.screen && M.client.screen.len)
//				var/obj/screen/plane_master/game_world/PM = locate(/obj/screen/plane_master/game_world) in M.client.screen
//				PM.backdrop(M.client.mob)

/datum/reagent/druqks/on_mob_end_metabolize(mob/living/M)
	M.clear_fullscreen("druqk")
	M.update_body_parts_head_only()
	if(M.client)
		REMOVE_TRAIT(M, TRAIT_DRUQK, "based")
		SSdroning.play_area_sound(get_area(M), M.client)
//		if(M.client.screen && M.client.screen.len)
///			var/obj/screen/plane_master/game_world/PM = locate(/obj/screen/plane_master/game_world) in M.client.screen
//			PM.backdrop(M.client.mob)

/obj/item/reagent_containers/powder/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	. = ..()
	///if the thrown object's target zone isn't the head
	if(thrownthing.target_zone != BODY_ZONE_PRECISE_NOSE)
		return
	if(iscarbon(hit_atom))
		var/mob/living/carbon/C = hit_atom
		if(canconsume(C, silent = TRUE))
			if(reagents.total_volume)
				playsound(C, 'sound/items/sniff.ogg', 100, FALSE)
				reagents.trans_to(C, 1, transfered_by = thrownthing.thrower, method = "swallow")
	qdel(src)

/obj/item/reagent_containers/powder/attack(mob/M, mob/user, def_zone)
	if(!canconsume(M, user))
		return FALSE

	if(user.zone_selected != BODY_ZONE_PRECISE_NOSE)
		return FALSE

	if(M == user)
		M.visible_message("<span class='notice'>[user] sniffs [src].</span>")
	else
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			var/obj/item/bodypart/CH = C.get_bodypart(BODY_ZONE_HEAD)
			if(!CH)
				to_chat(user, "<span class='warning'>[C.p_theyre(TRUE)] missing something.</span>")
			user.visible_message("<span class='danger'>[user] attempts to force [C] to inhale [src].</span>", \
								"<span class='danger'>[user] attempts to force me to inhale [src]!</span>")
			if(C.cmode)
				if(!CH.grabbedby)
					to_chat(user, "<span class='info'>[C.p_they(TRUE)] steals [C.p_their()] face from it.</span>")
					return FALSE
			if(!do_mob(user, M, 10))
				return FALSE

	playsound(M, 'sound/items/sniff.ogg', 100, FALSE)

	if(reagents.total_volume)
		reagents.trans_to(M, reagents.total_volume, transfered_by = user, method = "swallow")
	qdel(src)
	return TRUE

/*
/obj/item/reagent_containers/pill/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(!dissolvable || !target.is_refillable())
		return
	if(target.is_drainable() && !target.reagents.total_volume)
		to_chat(user, "<span class='warning'>[target] is empty! There's nothing to dissolve [src] in.</span>")
		return

	if(target.reagents.holder_full())
		to_chat(user, "<span class='warning'>[target] is full.</span>")
		return

	user.visible_message("<span class='warning'>[user] slips something into [target]!</span>", "<span class='notice'>I dissolve [src] in [target].</span>", null, 2)
	reagents.trans_to(target, reagents.total_volume, transfered_by = user)
	qdel(src)
*/
/obj/item/reagent_containers/powder/flour
	name = "powder"
	desc = ""
	gender = PLURAL
	icon_state = "flour"
	list_reagents = list(/datum/reagent/floure = 1)
	volume = 1
	sellprice = 0
/datum/reagent/floure
	name = "flower"
	description = ""
	color = "#FFFFFF" // rgb: 96, 165, 132

/datum/reagent/floure/on_mob_life(mob/living/carbon/M)
	if(prob(30))
		M.confused = max(M.confused+3,0)
	M.emote(pick("cough"))
	..()

/obj/item/reagent_containers/powder/flour/throw_impact(atom/hit_atom, datum/thrownthing/thrownthing)
	new /obj/effect/decal/cleanable/food/flour(get_turf(src))
	..()
	qdel(src)

/obj/item/reagent_containers/powder/flour/salt
	name = "salt"
	desc = ""
	gender = PLURAL
	icon_state = "salt"
	list_reagents = list(/datum/reagent/floure = 1)
	volume = 1

/obj/item/reagent_containers/powder/ozium
	name = "powder"
	desc = ""
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "ozium"
	possible_transfer_amounts = list()
	volume = 15
	list_reagents = list(/datum/reagent/ozium = 15)
	sellprice = 5

/datum/reagent/ozium
	name = "Ozium"
	description = ""
	color = "#60A584" // rgb: 96, 165, 132
	overdose_threshold = 16
	metabolization_rate = 0.2

/datum/reagent/ozium/overdose_process(mob/living/M)
	M.adjustToxLoss(0.25*REM, 0)
	..()
	. = 1

/datum/reagent/ozium/on_mob_life(mob/living/carbon/M)
	if(M.has_flaw(/datum/charflaw/addiction/junkie))
		M.sate_addiction()
	M.apply_status_effect(/datum/status_effect/buff/ozium)
	..()

/datum/reagent/ozium/overdose_start(mob/living/M)
	M.playsound_local(M, 'sound/misc/heroin_rush.ogg', 100, FALSE)
	M.visible_message("<span class='warning'>Blood runs from [M]'s nose.</span>")

/datum/reagent/ozium/overdose_process(mob/living/M)
	M.adjustToxLoss(10, 0)

/obj/item/reagent_containers/powder/moondust
	name = "moondust"
	desc = ""
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "moondust"
	possible_transfer_amounts = list()
	volume = 15
	list_reagents = list(/datum/reagent/moondust = 15)
	sellprice = 5

/datum/reagent/moondust/overdose_process(mob/living/M)
	M.adjustToxLoss(0.25*REM, 0)
	..()
	. = 1

/datum/reagent/moondust/on_mob_metabolize(mob/living/M)
	M.flash_fullscreen("can_you_see")
	animate(M.client, pixel_y = 1, time = 1, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -1, time = 1, flags = ANIMATION_RELATIVE)

/datum/reagent/moondust/on_mob_end_metabolize(mob/living/M)
	animate(M.client)

/datum/reagent/moondust/on_mob_life(mob/living/carbon/M)
	if(M.reagents.has_reagent(/datum/reagent/moondust_purest))
		M.Sleeping(40, 0)
	if(M.has_flaw(/datum/charflaw/addiction/junkie))
		M.sate_addiction()
	M.apply_status_effect(/datum/status_effect/buff/moondust)
	if(prob(10))
		M.flash_fullscreen("whiteflash")
	..()

/datum/reagent/moondust/overdose_start(mob/living/M)
	M.playsound_local(M, 'sound/misc/heroin_rush.ogg', 100, FALSE)
	M.visible_message("<span class='warning'>Blood runs from [M]'s nose.</span>")

/datum/reagent/moondust/overdose_process(mob/living/M)
	M.adjustToxLoss(10, 0)

/obj/item/reagent_containers/powder/moondust_purest
	name = "moondust"
	desc = ""
	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "moondust_purest"
	possible_transfer_amounts = list()
	volume = 18
	list_reagents = list(/datum/reagent/moondust_purest = 18)
	sellprice = 30

/datum/reagent/moondust_purest
	name = "Purest Moondust"
	description = ""
	color = "#bfc3b5"
	overdose_threshold = 50
	metabolization_rate = 0.2

/datum/reagent/moondust_purest/overdose_process(mob/living/M)
	M.adjustToxLoss(0.25*REM, 0)
	..()
	. = 1

/datum/reagent/moondust_purest/on_mob_metabolize(mob/living/M)
	M.playsound_local(M, 'sound/ravein/small/hello_my_friend.ogg', 100, FALSE)
	M.flash_fullscreen("can_you_see")
	M.overlay_fullscreen("purest_kaif", /obj/screen/fullscreen/purest)
	animate(M.client, pixel_y = 1, time = 1, loop = -1, flags = ANIMATION_RELATIVE)
	animate(pixel_y = -1, time = 1, flags = ANIMATION_RELATIVE)

/datum/reagent/moondust_purest/on_mob_end_metabolize(mob/living/M)
	animate(M.client)
	M.clear_fullscreen("purest_kaif")

/datum/reagent/moondust_purest/on_mob_life(mob/living/carbon/M)
	if(M.reagents.has_reagent(/datum/reagent/moondust))
		M.Sleeping(40, 0)
	if(M.has_flaw(/datum/charflaw/addiction/junkie))
		M.sate_addiction()
	M.apply_status_effect(/datum/status_effect/buff/moondust_purest)
	if(prob(20))
		M.flash_fullscreen("whiteflash")
	..()

/datum/reagent/moondust_purest/overdose_start(mob/living/M)
	M.playsound_local(M, 'sound/misc/heroin_rush.ogg', 100, FALSE)
	M.visible_message("<span class='warning'>Blood runs from [M]'s nose.</span>")

/datum/reagent/moondust_purest/overdose_process(mob/living/M)
	M.adjustToxLoss(10, 0)