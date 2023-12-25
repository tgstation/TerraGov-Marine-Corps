//Santa is back in town
/datum/emergency_call/santa
	name = "Santa's Workshop"
	base_probability = 75
	alignement_factor = 0


/datum/emergency_call/santa/print_backstory(mob/living/carbon/human/H)
	to_chat(H, "<B>You [pick("fed the reindeer and worked hard for 11 months a year", "worked hard to deliver presents to good boys and girls of all species", "survived the ice, snow, and low gravity working tirelessly for Santa", "were a master craftsman who snuck onto Santa's galactic sleigh ride")].</b>")
	to_chat(H, "<B>As part of Santa's entourage, you travel with him to deliver presents to all who deserve to be rewarded.</b>")
	to_chat(H, "<B>Santa travels the galaxy once a year, visiting every single inhabited planet in a single period of 24 standard hours. Santa maintains an active defense force to punish especially naughty sapients with lethal force, this defense force currently numbers more than 30,000 elves and ships.</b>")
	to_chat(H, "")
	to_chat(H, "<B>Today, while enroute to visit a TGMC vessel, [SSmapping.configs[SHIP_MAP].map_name], the artificial intelligence in Santa's sleigh detected an abnormally high level of naughtiness in the orbit of [SSmapping.configs[GROUND_MAP].map_name]. Santa has resolved to punish them in the spirit of Christmas!</b>")
	if(GLOB.round_statistics.number_of_grinches >= 1)
		to_chat(H, "<B>Eradicate all lifeforms aboard the ship to save Christmas, coal won't be enough this time. The only punishment Santa believes in now is hot lead!</B>")
	else
		to_chat(H, "<B>Punish the naughty </b>aliens</b> onboard the ship, coal won't be enough this time. The only punishment Santa believes in now is hot lead!</B>")

/datum/emergency_call/santa/create_member(datum/mind/M)
	. = ..()
	if(!.)
		return

	var/mob/original = M.current
	var/mob/living/carbon/human/H = .

	M.transfer_to(H, TRUE)

	if(original)
		qdel(original)

	//
	//Santa himself is a discount deathsquad leader, his elves are just fodder though and very poorly equipped
	//

	if(!leader)
		leader = H
		var/datum/job/J = SSjob.GetJobType(/datum/job/santa/leader)
		H.name = "Santa Claus"
		H.real_name = H.name
		H.apply_assigned_role_to_spawn(J)
		H.set_nutrition(NUTRITION_OVERFED * 2)
		H.grant_language(/datum/language/xenocommon)
		ADD_TRAIT(H, TRAIT_SANTA_CLAUS, TRAIT_SANTA_CLAUS)
		var/datum/action/innate/summon_present/present_spawn = new(H)
		present_spawn.give_action(H)
		var/datum/action/innate/summon_present_bomb/present_bomb_spawn = new(H)
		present_bomb_spawn.give_action(H)
		var/datum/action/innate/rejuv_self/selfhealing = new(H)
		selfhealing.give_action(H)
		var/datum/action/innate/summon_elves/elfsummoning = new(H)
		elfsummoning.give_action(H)
		var/datum/action/innate/heal_elf/fixelfslave = new(H)
		fixelfslave.give_action(H)
		var/datum/action/innate/elf_swap/swapelf = new(H)
		swapelf.give_action(H)
		if(GLOB.round_statistics.number_of_grinches >= 1)
			to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are Santa Claus! Eradicate all </b>marines and aliens</b> with overwhelming firepower! </b>Leave none of them alive!!</b>.")]</p>")
		else
			to_chat(H, "<p style='font-size:1.5em'>[span_notice("You are Santa Claus! Punish all the naughty </b>aliens</b> with overwhelming firepower, starting with their cowardly queen hiding on the ship.")]</p>")
		return

	ADD_TRAIT(H, TRAIT_CHRISTMAS_ELF, TRAIT_CHRISTMAS_ELF)
	var/datum/job/J = SSjob.GetJobType(/datum/job/santa)
	H.apply_assigned_role_to_spawn(J)
	H.name = "Elf [rand(1,999)]"
	H.real_name = H.name
	var/datum/action/innate/elf_recall/recallingelf = new(H)
	recallingelf.give_action(H)
	print_backstory(H)
	if(GLOB.round_statistics.number_of_grinches >= 1)
		to_chat(H, span_notice("You are a member of Santa's loyal workforce, assist Santa in purging the marine ship of </b>all life</b>, human and xeno!"))
	else
		to_chat(H, span_notice("You are a member of Santa's loyal workforce, assist Santa in whatever way you can!"))

/datum/action/innate/summon_present
	name = "Summon Present"
	action_icon_state = "present"

/datum/action/innate/summon_present/Activate()
	var/mob/living/carbon/human/santamob = usr
	to_chat(santamob, span_notice("You begin rifling through your bag, looking for a present."))
	if(!do_after(santamob, 7 SECONDS))
		to_chat(santamob, "You give up looking for a present.")
		return
	var/obj/item/a_gift/santa/spawnedpresent = new (get_turf(santamob))
	santamob.put_in_hands(spawnedpresent)

/datum/action/innate/summon_present_bomb
	name = "Summon Explosive Present"
	action_icon_state = "dangerpresent"

/datum/action/innate/summon_present_bomb/Activate()
	var/mob/living/carbon/human/santamob = usr
	to_chat(santamob, span_warning("You begin rifling through your bag, looking for a present bomb."))
	if(!do_after(santamob, 3 SECONDS))
		to_chat(santamob, "You stop searching for a present grenade.")
		return
	var/obj/item/explosive/grenade/gift/spawnedpresentbomb = new (get_turf(santamob))
	santamob.put_in_hands(spawnedpresentbomb)

/datum/action/innate/rejuv_self
	name = "Revitalize Self"
	action_icon_state = "santa_heal"

/datum/action/innate/rejuv_self/Activate()
	var/mob/living/carbon/human/santamob = usr
	to_chat(santamob, span_notice("You begin summoning Christmas magic to heal your rounds."))
	if(!do_after(santamob, 2 MINUTES))
		to_chat(santamob, span_notice("With a burst of holiday spirit you heal your wounds, you're as good as new!"))
		return
	santamob.revive()

/datum/action/innate/summon_elves
	name = "Summon Elves"
	action_icon_state = "santa_summon"

/datum/action/innate/summon_elves/Activate()
	var/mob/living/carbon/human/santamob = usr
	to_chat(santamob, span_notice("You begin summoning your faithful workers to your side."))
	if(!do_after(santamob, 15 SECONDS))
		to_chat(santamob, "You decide not to summon your elves, they aren't much of a help anyway")
		return
	for(var/mob/living/carbon/human/elves in GLOB.humans_by_zlevel["[santamob.z]"])
		if(HAS_TRAIT(elves, TRAIT_CHRISTMAS_ELF))
			elves.forceMove(get_turf(santamob))

/datum/action/innate/heal_elf
	name = "Heal Elf"
	action_icon_state = "heal_elf"

/datum/action/innate/heal_elf/Activate()
	var/list/elflist = list()
	var/mob/living/carbon/human/santamob = usr
	to_chat(santamob, "You concentrating on healing your elves...")
	if(!do_after(santamob, 10 SECONDS))
		to_chat(santamob, "You decide there are more important things to concentrate on...")
		return
	for(var/mob/living/carbon/human/elves in GLOB.human_mob_list)
		if(get_dist(santamob, elves) > 10)
			continue
		if(HAS_TRAIT(elves, TRAIT_CHRISTMAS_ELF))
			elflist += elves
	for(var/mob/living/carbon/human/blessedelf in elflist)
		if(blessedelf.stat == DEAD) //this is basically a copypaste of defib logic, but with magic not paddles
			var/heal_target = blessedelf.get_death_threshold() - blessedelf.health + 1
			var/all_loss = blessedelf.getBruteLoss() + blessedelf.getFireLoss() + blessedelf.getToxLoss()
			blessedelf.setOxyLoss(0)
			blessedelf.updatehealth()
			if(all_loss && (heal_target > 0))
				var/brute_ratio = blessedelf.getBruteLoss() / all_loss
				var/burn_ratio = blessedelf.getFireLoss() / all_loss
				var/tox_ratio = blessedelf.getToxLoss() / all_loss
				blessedelf.adjustBruteLoss(-10)
				blessedelf.adjustFireLoss(-10)
				blessedelf.adjustToxLoss(-10)
				blessedelf.setOxyLoss(0)
				if(tox_ratio)
					blessedelf.adjustToxLoss(-(tox_ratio * heal_target))
				blessedelf.heal_overall_damage(brute_ratio*heal_target, burn_ratio*heal_target, TRUE)
				blessedelf.updatehealth()
				blessedelf.set_stat(UNCONSCIOUS)
				blessedelf.emote("gasp")
		else //if the elf is alive heal them some
			to_chat(blessedelf, span_notice("You feel the chill of Christmas magic and your wounds are healed!"))
			blessedelf.setOxyLoss(0)
			blessedelf.adjustBruteLoss(-30)
			blessedelf.adjustFireLoss(-30)
			blessedelf.adjustToxLoss(-30)

/datum/action/innate/summon_paperwork
	name = "Summon Paperwork"
	action_icon_state = "paper"

/datum/action/innate/summon_paperwork/Activate()
	var/mob/living/carbon/human/santamob = usr
	to_chat(santamob, span_notice("You begin producing a binding employment contract."))
	if(!do_after(santamob, 3 SECONDS))
		to_chat(santamob, "You stop producing a contract.")
		return
	to_chat(santamob, span_notice("With a flourish, you produce an employment contract and a pen."))
	var/obj/item/paper/santacontract/newcontract = new (get_turf(santamob))
	santamob.put_in_hands(newcontract)
	var/obj/item/tool/pen/newpen = new (get_turf(santamob))
	santamob.put_in_hands(newpen)

/datum/action/innate/elf_swap
	name = "Swap with elf"
	action_icon_state = "santaswap"

/datum/action/innate/elf_swap/Activate()
	var/list/elflist = list()
	var/storedzlevel
	var/mob/living/carbon/human/santamob = usr
	for(var/mob/living/carbon/human/elves in GLOB.alive_human_list)
		if(HAS_TRAIT(elves, TRAIT_CHRISTMAS_ELF))
			elflist += elves
	var/mob/living/carbon/human/swappedelf = tgui_input_list(santamob , "Choose an elf to swap with", "Elf swapping", elflist)
	to_chat(santamob, span_notice("You begin summoning your Christmas magic to swap places with an elf..."))
	to_chat(swappedelf, span_notice("You feel odd, as though you're in two places at once..."))
	if(HAS_TRAIT(santamob, TRAIT_TELEPORTED_ACROSS_ZLEVELS))
		if(swappedelf.z != santamob.z)
			to_chat(santamob, span_warning("You teleported too great a distance recently, you'll need to wait before teleporting that far again..."))
			return
	if(!do_after(santamob, 5 SECONDS))
		to_chat(santamob, span_notice("You stop preparing to switch places with a lowly elf..."))
		return
	storedzlevel = santamob.z
	var/turf/elfturf = get_turf(swappedelf)
	var/turf/santaturf = get_turf(santamob)
	santamob.forceMove(elfturf)
	swappedelf.forceMove(santaturf)
	swappedelf.Stun(3 SECONDS)
	if(storedzlevel == santamob.z)
		santamob.Stun(3 SECONDS)
		to_chat(santamob, span_notice("You struggle to get your bearings after the swap..."))
	else
		santamob.Stun(20 SECONDS)
		ADD_TRAIT(santamob, TRAIT_TELEPORTED_ACROSS_ZLEVELS, TRAIT_SANTA_CLAUS)
		addtimer(CALLBACK(santamob, TYPE_PROC_REF(/mob/living/carbon/human, remove_teleport_trait), santamob), 3 MINUTES) //extremely snowflaky proc, viewer beware
		to_chat(santamob, span_warning("The strain of travelling across such a great distance unbalances you..."))
	to_chat(swappedelf, span_notice("As the world reels around you, you struggle to get your bearings..."))

/datum/action/innate/elf_recall
	name = "Return to Santa"
	action_icon_state = "elf_recall"

/datum/action/innate/elf_recall/Activate()
	var/list/santalist = list()
	var/mob/living/carbon/human/elfmob = usr
	for(var/mob/living/carbon/human/santas in GLOB.humans_by_zlevel["[elfmob.z]"])
		if(HAS_TRAIT(santas, TRAIT_SANTA_CLAUS))
			santalist += santas
	if(!length(santalist))
		to_chat(elfmob, span_warning("You can't find Santa! There is nobody to return to..."))
		return
	to_chat(elfmob, span_notice("You on concentrate on gathering enough magic to return to Santa..."))
	if(!do_after(elfmob, 10 SECONDS))
		to_chat(elfmob, "You decide there are more important things to do...")
		return
	var/mob/living/carbon/human/selectedsanta = pick(santalist)
	elfmob.forceMove(get_turf(selectedsanta))
