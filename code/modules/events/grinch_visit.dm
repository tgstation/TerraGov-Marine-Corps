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
		var/mob/living/carbon/human/spawnedhuman = new /mob/living/carbon/human(target)
		var/datum/job/J = SSjob.GetJobType(/datum/job/santa/eventspawn)
		spawnedhuman.name = "The Grinch"
		spawnedhuman.real_name = spawnedhuman.name
		spawnedhuman.apply_assigned_role_to_spawn(J)
		spawnedhuman.grant_language(/datum/language/xenocommon)
		ADD_TRAIT(spawnedhuman, TRAIT_ACTUAL_CHRISTMAS_GRINCH, TRAIT_ACTUAL_CHRISTMAS_GRINCH)
		var/datum/action/innate/summon_present/present_spawn = new(spawnedhuman)
		present_spawn.give_action(spawnedhuman)
		var/datum/action/innate/summon_elves/elfsummoning = new(spawnedhuman)
		elfsummoning.give_action(spawnedhuman)
		var/datum/action/innate/elf_swap/swapelf = new(spawnedhuman)
		swapelf.give_action(spawnedhuman)
		var/datum/action/innate/summon_paperwork/summon_contract = new(spawnedhuman)
		summon_contract.give_action(spawnedhuman)
		spawnedhuman.offer_mob()

/datum/action/innate/summon_garbage
	name = "Summon Present"
	action_icon_state = "present"

/datum/action/innate/summon_garbage/Activate()
	var/mob/living/carbon/human/santamob = usr
	to_chat(santamob, span_notice("You begin filling a spare garbage bag with the most vile stuff you can find."))
	if(!do_after(santamob, 3 SECONDS, NONE))
		to_chat(santamob, "You give up looking for garbage.")
		return
	if(locate(/obj/item/a_gift/santa) in get_turf(santamob))
		to_chat(santamob, "There's a garbage bag here already, better use that one instead.")
		return
	var/obj/item/a_gift/santa/spawnedpresent = new (get_turf(santamob))
	santamob.put_in_hands(spawnedpresent)

/obj/item/storage/bag/trash/grinch
	name = "trash bag"
	desc = "It's the heavy-duty black polymer kind. Time to take out the trash!"
	icon_state = "trashbag3"
	worn_icon_state = "trashbag"
	var/pieces_of_trash = 3

/obj/item/storage/bag/trash/grinch/Initialize(mapload, ...)
	. = ..()
	pieces_of_trash = rand(1,15)

/obj/item/storage/bag/trash/grinch/throw_impact(atom/hit_atom, speed, bounce)
	. = ..()
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/unfortunatehuman = hit_atom
		unfortunatehuman.Stun(3 SECONDS)
		unfortunatehuman.Knockdown(1 SECONDS)
		to_chat(hit_atom, span_notice("The garbage bag hits you right in the face, stunning you for a second..."))

