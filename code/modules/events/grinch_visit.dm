//Supplies are dropped onto the map for both factions to fight over
/datum/round_event_control/grinch_visit
	name = "Grinch Visit"
	typepath = /datum/round_event/grinch_visit
	weight = 0 ///manual trigger most of the time, somebody needs to keep an eye on the grinch
	earliest_start = 30 MINUTES
	max_occurrences = 1

	gamemode_blacklist = list("Crash")

/datum/round_event/grinch_visit
	announce_when = 0
	///used to hold location of christmas tree for spawning purposes
	var/turf/christmastreeturf

/datum/round_event/grinch_visit/start()
	for(var/obj/structure/flora/tree/pine/xmas/presents/christmastree)
		if(christmastree.unlimited)
			continue
		else
			christmastreeturf = christmastree
	place_grinch()

/datum/round_event/grinch_visit/announce()
	var/alert = pick( "Excessive Christmas cheer detected. Be advised: the Grinch may be lurking nearby, spreading his foul disdain for all things festive.",
	"Radar has picked up a single spiky signature skulking in the darkness. Approach with caution.",
	"Attention crew: the Grinch has been spotted shipside. Brace yourselves for complaints about carolers and attempts to sabotage holiday spirit.",
	"Caution: Eggnog spill detected shipside. Investigate immediately, and ensure the Grinch hasn’t swapped it for something unpleasant.",
	"Deck the halls with caution signs: Reports of tinsel sabotage shipside. Proceed carefully, and watch out for a green figure with a sinister scowl.",
	)
	priority_announce(alert)

///proc for spawning santa(s) around christmas tree
/datum/round_event/grinch_visit/proc/place_grinch()
		var/turf/target = locate(christmastreeturf.x + rand(-3, 3), christmastreeturf.y + rand(-3, 3), christmastreeturf.z)
		var/mob/living/carbon/human/spawnedhuman = new /mob/living/carbon/human(target)
		spawnedhuman.h_style = "Bald"
		spawnedhuman.f_style = "Shaved"
		var/datum/job/J = SSjob.GetJobType(/datum/job/santa/grinch)
		spawnedhuman.name = "The Grinch"
		spawnedhuman.real_name = spawnedhuman.name
		spawnedhuman.apply_assigned_role_to_spawn(J)
		spawnedhuman.grant_language(/datum/language/xenocommon)
		ADD_TRAIT(spawnedhuman, TRAIT_ACTUAL_CHRISTMAS_GRINCH, TRAIT_ACTUAL_CHRISTMAS_GRINCH)
		var/datum/action/innate/summon_garbage/present_garbage = new(spawnedhuman)
		present_garbage.give_action(spawnedhuman)
		var/datum/action/innate/return_to_point/returntopoint = new(spawnedhuman)
		returntopoint.give_action(spawnedhuman)
		var/datum/action/innate/vandalize_area/vandalizearea = new(spawnedhuman)
		vandalizearea.give_action(spawnedhuman)
		var/datum/action/innate/summon_coal/summoncoal = new(spawnedhuman)
		summoncoal.give_action(spawnedhuman)
		var/datum/action/innate/summon_flashbang_trash/summonflashbang = new(spawnedhuman)
		summonflashbang.give_action(spawnedhuman)
		var/datum/action/innate/summon_beartrap/summonbear = new(spawnedhuman)
		summonbear.give_action(spawnedhuman)
		spawnedhuman.offer_mob()

/datum/action/innate/summon_garbage
	name = "Summon Garbage"
	action_icon_state = "bag"

/datum/action/innate/summon_garbage/Activate()
	var/mob/living/carbon/human/grinchmob = usr
	to_chat(grinchmob, span_notice("You begin filling a spare garbage bag with the most vile stuff you can find."))
	if(!do_after(grinchmob, 2 SECONDS, NONE))
		to_chat(grinchmob, "You give up looking for garbage.")
		return
	if(locate(/obj/item/storage/bag/trash/grinch) in get_turf(grinchmob))
		to_chat(grinchmob, "There's a garbage bag here already, better use that one instead.")
		return
	var/obj/item/storage/bag/trash/grinch/spawnedpresent = new (get_turf(grinchmob))
	grinchmob.put_in_hands(spawnedpresent)

/obj/item/storage/bag/trash/grinch
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon_state = "trashbag3"
	worn_icon_state = "trashbag"
	var/pieces_of_trash = 3

/obj/item/storage/bag/trash/grinch/Initialize(mapload, ...)
	. = ..()
	pieces_of_trash = rand(5,20)

/obj/item/storage/bag/trash/grinch/throw_impact(atom/hit_atom, speed, bounce)
	. = ..()
	var/list/nearbyturfs = list()
	for(var/turf/near_turfs in range(3))
		nearbyturfs += near_turfs
	new /obj/effect/decal/cleanable/dirt(get_turf(hit_atom)) //spawn dirt where the bag originally hit
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/unfortunatehuman = hit_atom
		unfortunatehuman.Stun(6 SECONDS)
		unfortunatehuman.Knockdown(3 SECONDS)
		to_chat(unfortunatehuman, span_notice("The garbage bag hits you right in the face, stunning you for a second..."))
		balloon_alert_to_viewers("The [src] explodes into a pile trash as it hits [unfortunatehuman]'s face" ,ignored_mobs = unfortunatehuman)
		unfortunatehuman.reagents.add_reagent(/datum/reagent/grinchium, 15)
	for(var/thrown_trashes in nearbyturfs)
		if(prob(25) && !isclosedturf(thrown_trashes))
			var/obj/item/trash/trashestothrow = pick(typesof(/obj/item/trash))
			new trashestothrow(thrown_trashes)
	qdel(src)

/obj/item/storage/bag/trash/grinch/flashbang
	name = "trash bag filled with wires"
	desc = "The Grinch has packed this bag with a few treats for ruining Christmas."
	///The range where the maximum effects are applied
	var/inner_range = 2
	///The range where the moderate effects are applied
	var/outer_range = 5
	///The the max of the flashbang
	var/max_range = 7

/obj/item/storage/bag/trash/grinch/flashbang/throw_impact(atom/hit_atom, speed, bounce)
	var/turf/target_turf = get_turf(hit_atom)
	playsound(target_turf, SFX_FLASHBANG, 65)
	for(var/mob/living/carbon/victim in hearers(max_range, target_turf))
		if(isxeno(victim) || HAS_TRAIT(victim, TRAIT_ACTUAL_CHRISTMAS_GRINCH))
			continue
		if(!HAS_TRAIT(victim, TRAIT_FLASHBANGIMMUNE))
			bang(target_turf, victim)
	var/list/nearbyturfs = list()
	for(var/turf/near_turfs in range(4))
		nearbyturfs += near_turfs
	for(var/thrown_trashes in nearbyturfs)
		if(prob(25) && !isclosedturf(thrown_trashes))
			var/obj/item/trash/trashestothrow = pick(typesof(/obj/item/trash))
			new trashestothrow(thrown_trashes)
	qdel(src)

	new/obj/effect/particle_effect/smoke/flashbang(target_turf)
	. = ..()

///Applies the flashbang effects based off range and ear protection
/obj/item/storage/bag/trash/grinch/flashbang/proc/bang(turf/T , mob/living/carbon/M)
	to_chat(M, span_danger("BANG"))

	//Checking for protection
	var/ear_safety = 0
	if(iscarbon(M))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(istype(H.wear_ear, /obj/item/clothing/ears/earmuffs))
				ear_safety += 2
			if(istype(H.head, /obj/item/clothing/head/helmet/riot))
				ear_safety += 2
			if(istype(H.head, /obj/item/clothing/head/helmet/marine/veteran/pmc/commando))
				ear_safety += INFINITY
				inner_range = null
				outer_range = null
				max_range = null

	if(get_dist(M, T) <= inner_range)
		inner_effect(T, M, ear_safety)
	else if(get_dist(M, T) <= outer_range)
		outer_effect(T, M, ear_safety)
	else
		max_range_effect(T, M, ear_safety)

	base_effect(T, M, ear_safety) //done afterwards as it contains the eye/ear damage checks

///The effects applied to all mobs in range
/obj/item/storage/bag/trash/grinch/flashbang/proc/base_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(M.flash_act())
		M.apply_effects(stun = 2 SECONDS, paralyze = 1 SECONDS)
	if(M.ear_damage >= 15)
		to_chat(M, span_warning("Your ears start to ring badly!"))
	else
		if(M.ear_damage >= 5)
			to_chat(M, span_warning("Your ears start to ring!"))

///The effects applied to mobs in the inner_range
/obj/item/storage/bag/trash/grinch/flashbang/proc/inner_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(ear_safety > 0)
		M.apply_effects(stun = 1 SECONDS, paralyze = 0.5 SECONDS)
	else
		M.apply_effects(stun = 3 SECONDS, paralyze = 1 SECONDS)
		if((prob(14) || (M == src.loc && prob(70))))
			M.adjust_ear_damage(rand(1, 10),15)
		else
			M.adjust_ear_damage(rand(0, 5),10)

///The effects applied to mobs in the outer_range
/obj/item/storage/bag/trash/grinch/flashbang/proc/outer_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(!ear_safety)
		M.apply_effect(8 SECONDS, EFFECT_STUN)
		M.adjust_ear_damage(rand(0, 3),8)

///The effects applied to mobs outside of outer_range
/obj/item/storage/bag/trash/grinch/flashbang/proc/max_range_effect(turf/T , mob/living/carbon/M, ear_safety)
	if(!ear_safety)
		M.apply_effect(4 SECONDS, EFFECT_STUN)
		M.adjust_ear_damage(rand(0, 1),6)

/datum/action/innate/return_to_point
	name = "Return to safe zone"
	action_icon_state = "return_arrow"
	var/returning = FALSE
	var/turf/safezone

/datum/action/innate/return_to_point/Activate()
	if(!returning)
		to_chat(usr, "You begin establishing this as a safe hide out to return to in the event of danger.")
		if(!do_after(usr, 5 SECONDS, NONE))
			to_chat(usr, "You give up establishing this as a safe area to return to.")
			return
		safezone = get_turf(usr)
		returning = !returning
	else
		to_chat(usr, "You concentrate on returning to your safezone...")
		if(isspaceturf(get_turf(safezone)))
			returning = !returning
			return
		if(!do_after(usr, 1 SECONDS, NONE))
			to_chat(usr, "You give up on escaping to your safe zone.")
			return
		returning = !returning
		usr.forceMove(safezone)

/datum/action/innate/vandalize_area
	name = "Vandalize area"
	action_icon_state = "rune"
	var/list/nearbyturfs = list()
	var/pieces_of_trash = 10

/datum/action/innate/vandalize_area/Activate()
	to_chat(usr, "You start ruining the surrounding area...")
	if(!do_after(usr, 3 SECONDS, NONE))
		to_chat(usr, "You give up on ruining Christmas spirit through sheer property destruction.")
		return
	pieces_of_trash = rand(5,20)
	for(var/turf/near_turfs in range(3))
		nearbyturfs += near_turfs
	for(var/trashestothrow in nearbyturfs)
		if(prob(25) && !isclosedturf(trashestothrow))
			var/obj/item/trash/selectedtrash = pick(typesof(/obj/item/trash))
			new selectedtrash(trashestothrow)
	for(var/turfsinlist in nearbyturfs)
		if(locate(/obj/effect/decal/cleanable/grinch_decal) in turfsinlist)
			continue
		if(prob(25) && !isclosedturf(turfsinlist))
			var/obj/effect/decal/cleanable/grinch_decal/selecteddecal = pick(typesof(/obj/effect/decal/cleanable/grinch_decal))
			new selecteddecal(turfsinlist)

/datum/action/innate/summon_coal
	name = "Summon Coal"
	action_icon_state = "coal"

/datum/action/innate/summon_coal/Activate()
	var/mob/living/carbon/human/grinchmob = usr
	to_chat(grinchmob, span_notice("You begin rifling through your bag, looking for coal."))
	if(!do_after(grinchmob, 1 SECONDS, NONE))
		to_chat(grinchmob, "You give up looking for coal.")
		return
	if(locate(/obj/item/stack/throwing_knife/coal) in get_turf(grinchmob))
		to_chat(grinchmob, "There's coal here already, better use that one instead.")
		return
	var/obj/item/stack/throwing_knife/coal/spawnedcoal = new (get_turf(grinchmob))
	grinchmob.put_in_hands(spawnedcoal)

/datum/action/innate/summon_flashbang_trash
	name = "Summon Explosive Trashbag"
	action_icon_state = "bgrenade"

/datum/action/innate/summon_flashbang_trash/Activate()
	var/mob/living/carbon/human/grinchmob = usr
	to_chat(grinchmob, span_notice("You begin filling a trashbag with a special contraption you've made..."))
	if(!do_after(grinchmob, 7 SECONDS, NONE))
		to_chat(grinchmob, "You give up assembling your invention.")
		return
	if(locate(/obj/item/storage/bag/trash/grinch/flashbang) in get_turf(grinchmob))
		to_chat(grinchmob, "There's another one of your invention here already, better use that one instead.")
		return
	var/obj/item/storage/bag/trash/grinch/flashbang/spawnedcoal = new (get_turf(grinchmob))
	grinchmob.put_in_hands(spawnedcoal)

/datum/action/innate/summon_beartrap
	name = "Summon Beartrap"
	action_icon_state = "beartrap"

/datum/action/innate/summon_beartrap/Activate()
	var/mob/living/carbon/human/grinchmob = usr
	to_chat(grinchmob, span_notice("You begin rifling through your bag, looking for a trap."))
	if(!do_after(grinchmob, 1 SECONDS, NONE))
		to_chat(grinchmob, "You give up looking for a trap.")
		return
	if(locate(/obj/item/beartrap) in get_turf(grinchmob))
		to_chat(grinchmob, "There's a trap here already, better use that one instead.")
		return
	var/obj/item/beartrap/spawnedcoal = new (get_turf(grinchmob))
	grinchmob.put_in_hands(spawnedcoal)

/obj/item/beartrap
	name = "bear trap"
	desc = "It's a heavy duty bear trap!"
	icon = 'icons/obj/restraints.dmi'
	icon_state = "beartrap"
	var/deployed = FALSE
	///connection list for huggers
	var/static/list/listen_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(trigger_trap),
	)

/obj/item/beartrap/Initialize(mapload, ...)
	. = ..()
	AddElement(/datum/element/connect_loc, listen_connections)

/obj/item/beartrap/proc/trigger_trap(datum/source, atom/movable/AM, oldloc, oldlocs)
	SIGNAL_HANDLER
	if(!deployed)
		return
	if(HAS_TRAIT(AM, TRAIT_ACTUAL_CHRISTMAS_GRINCH))
		return
	if(ishuman(AM))
		var/mob/living/carbon/crosser = AM
		crosser.visible_message(span_warning("The [src] closes on [crosser]'s body!"), span_danger("You are gripped by [src]!"))
		crosser.ParalyzeNoChain(6 SECONDS)
		crosser.Stun(9 SECONDS)
	qdel(src)

/obj/item/beartrap/attack_self(mob/M)
	to_chat(M, "You start deploying a bear trap.")
	if(!do_after(M, 1 SECONDS, NONE))
		to_chat(M, "You give up deploying a trap.")
		return
	deployed = TRUE
	forceMove(get_turf(M))
	anchored = TRUE
	icon_state = "beartrap1"

/obj/item/beartrap/attack_self(mob/M)
	to_chat(M, "You start deploying a bear trap.")
	if(!do_after(M, 1 SECONDS, NONE))
		to_chat(M, "You give up deploying a trap.")
		return
	deployed = TRUE
	forceMove(get_turf(M))
	anchored = TRUE
	icon_state = "beartrap1"

/obj/item/beartrap/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_ACTUAL_CHRISTMAS_GRINCH) || !istype(attacking_item, /obj/item/weapon || user.a_intent != INTENT_HARM))
		return
	to_chat(user, "You start disarming the [src].")
	if(!do_after(user, 1 SECONDS, NONE))
		to_chat(user, "You give up disarming the [src]")
		return
	to_chat(user, "You disarm the [src].")
	qdel(src)

/obj/item/beartrap/throw_impact(atom/hit_atom, speed, bounce)
	. = ..()
	if(prob(70))
		return
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/unfortunatehuman = hit_atom
		unfortunatehuman.Stun(6 SECONDS)
		unfortunatehuman.Knockdown(1 SECONDS)
		to_chat(hit_atom, "You the undeployed [src] latches onto you.")
