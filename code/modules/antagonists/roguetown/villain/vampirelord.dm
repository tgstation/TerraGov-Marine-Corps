/// DEFINITIONS ///
#define VAMP_LEVEL_ONE 10000
#define VAMP_LEVEL_TWO 12000
#define VAMP_LEVEL_THREE 15000
#define VAMP_LEVEL_FOUR 20000

#define MOBSTATS list("strength", "perception", "intelligence", "constitution", "endurance", "speed", "fortune")

/datum/antagonist/vampirelord
	name = "Vampire Lord"
	roundend_category = "Vampires"
	antagpanel_category = "Vampire"
	job_rank = ROLE_VAMPIRE
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "vampire"
	confess_lines = list("I AM ANCIENT", "I AM THE LAND", "CHILD OF KAIN!")
	var/isspawn = FALSE
	var/disguised = FALSE
	var/ascended = FALSE
	var/starved = FALSE
	var/sired = FALSE
	var/vamplevel = 0
	var/vitae = 1000
	var/vmax = 2000
	var/obj/structure/vampire/bloodpool/mypool
	var/last_transform
	var/cache_skin
	var/cache_eyes
	var/cache_hair
	var/obj/effect/proc_holder/spell/targeted/shapeshift/bat/batform //attached to the datum itself to avoid cloning memes, and other duplicates
	var/obj/effect/proc_holder/spell/targeted/shapeshift/gaseousform/gas

/datum/antagonist/vampirelord/examine_friendorfoe(datum/antagonist/examined_datum,mob/examiner,mob/examined)
	if(istype(examined_datum, /datum/antagonist/vampirelord/lesser))
		return "<span class='boldnotice'>A vampire spawn.</span>"
	if(istype(examined_datum, /datum/antagonist/vampirelord))
		return "<span class='boldnotice'>A Vampire Lord!.</span>"
	if(istype(examined_datum, /datum/antagonist/zombie))
		return "<span class='boldnotice'>Another deadite.</span>"
	if(istype(examined_datum, /datum/antagonist/skeleton))
		return "<span class='boldnotice'>Another deadite.</span>"

/datum/antagonist/vampirelord/on_gain()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	C.vampires |= owner
	. = ..()
	owner.special_role = name
	ADD_TRAIT(owner.current, RTRAIT_STRONGBITE, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOFATSTAM, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOHUNGER, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOBREATH, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOPAIN, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_TOXIMMUNE, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_NOSLEEP, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_LIMPDICK, TRAIT_GENERIC)
	ADD_TRAIT(owner.current, TRAIT_VAMPMANSION, TRAIT_GENERIC)
	owner.current.cmode_music = 'sound/music/combatvamp.ogg'
	var/obj/item/organ/eyes/eyes = owner.current.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.Remove(owner.current,1)
		QDEL_NULL(eyes)
	eyes = new /obj/item/organ/eyes/night_vision/zombie
	eyes.Insert(owner.current)
	owner.current.AddSpell(new /obj/effect/proc_holder/spell/targeted/transfix)
	owner.current.verbs |= /mob/living/carbon/human/proc/vamp_regenerate
	owner.current.verbs |= /mob/living/carbon/human/proc/vampire_telepathy
	vamp_look()
	if(isspawn)
		owner.current.verbs |= /mob/living/carbon/human/proc/disguise_button
		add_objective(/datum/objective/vlordserve)
		finalize_vampire_lesser()
		for(var/obj/structure/vampire/bloodpool/mansion in world)
			mypool = mansion
		equip_spawn()
		greet()
		addtimer(CALLBACK(owner.current, /mob/living/carbon/human/.proc/spawn_pick_class, "VAMPIRE SPAWN"), 5 SECONDS)
	else
		forge_vampirelord_objectives()
		finalize_vampire()
		owner.current.verbs |= /mob/living/carbon/human/proc/demand_submission
		owner.current.verbs |= /mob/living/carbon/human/proc/punish_spawn
		for(var/obj/structure/vampire/bloodpool/mansion in world)
			mypool = mansion
		equip_lord()
		addtimer(CALLBACK(owner.current, /mob/living/carbon/human/.proc/choose_name_popup, "VAMPIRE LORD"), 5 SECONDS)
		greet()
	return ..()
// OLD AND EDITED
/datum/antagonist/vampirelord/proc/equip_lord()
	owner.unknow_all_people()
	for(var/datum/mind/MF in get_minds())
		owner.become_unknown_to(MF)
	for(var/datum/mind/MF in get_minds("Vampire Spawn"))
		owner.i_know_person(MF)
		owner.person_knows_me(MF)

	var/mob/living/carbon/human/H = owner.current
	if(H.mobid in GLOB.character_list)
		GLOB.character_list[H.mobid] = null
	GLOB.chosen_names -= H.real_name
	if(H.dna.species?.id != "human" && H.dna.species?.id != "elf")
		H.age = AGE_ADULT
		if(prob(50))
			H.set_species(/datum/species/human/northern)
		else
			H.set_species(/datum/species/elf/snow) //setspecies randomizes body
		H.after_creation()
	H.equipOutfit(/datum/outfit/job/roguetown/vamplord)

	return TRUE

/datum/antagonist/vampirelord/proc/equip_spawn()
	owner.unknow_all_people()
	for(var/datum/mind/MF in get_minds())
		owner.become_unknown_to(MF)
	for(var/datum/mind/MF in get_minds("Vampire Spawn"))
		owner.i_know_person(MF)
		owner.person_knows_me(MF)

	var/mob/living/carbon/human/H = owner.current
	if(H.mobid in GLOB.character_list)
		GLOB.character_list[H.mobid] = null
	GLOB.chosen_names -= H.real_name
	owner.adjust_skillrank(/datum/skill/magic/blood, 2, TRUE)
	owner.current.ambushable = FALSE

/mob/living/carbon/human/proc/spawn_pick_class()
	var/list/classoptions = list("Bard", "Fisher", "Hunter", "Miner", "Peasant", "Woodcutter", "Cheesemaker", "Blacksmith", "Carpenter", "Rogue", "Treasure Hunter", "Mage", "Sorceress")
	var/list/visoptions = list()

	for(var/T in 1 to 5)
		var/picked = pick(classoptions)
		visoptions |= picked

	var/selected = input(src, "Which class was I?", "VAMPIRE SPAWN") as anything in visoptions

	for(var/datum/advclass/A in GLOB.adv_classes)
		if(A.name == selected)
			equipOutfit(A.outfit)
			return

/datum/outfit/job/roguetown/vamplord/pre_equip(mob/living/carbon/human/H)
	..()
	H.mind.adjust_skillrank(/datum/skill/magic/blood, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 5, TRUE)
	pants = /obj/item/clothing/under/roguetown/tights/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/vampire
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	head  = /obj/item/clothing/head/roguetown/vampire
	beltl = /obj/item/roguekey/vampire
	cloak = /obj/item/clothing/cloak/cape/puritan
	shoes = /obj/item/clothing/shoes/roguetown/boots
	backl = /obj/item/storage/backpack/rogue/satchel/black
	H.ambushable = FALSE

////////Outfits////////
/obj/item/clothing/under/roguetown/platelegs/vampire
	name = "ancient plate greaves"
	desc = ""
	gender = PLURAL
	icon_state = "vpants"
	item_state = "vpants"
	sewrepair = FALSE
	armor = list("melee" = 100, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	prevent_crits = list(BCLASS_CUT, BCLASS_CHOP, BCLASS_BLUNT)
	blocksound = PLATEHIT
	var/do_sound = FALSE
	drop_sound = 'sound/foley/dropsound/armor_drop.ogg'
	anvilrepair = /datum/skill/craft/armorsmithing
	r_sleeve_status = SLEEVE_NOMOD
	l_sleeve_status = SLEEVE_NOMOD

/obj/item/clothing/suit/roguetown/shirt/vampire
	slot_flags = ITEM_SLOT_SHIRT
	name = "regal silks"
	desc = ""
	body_parts_covered = CHEST|GROIN|LEGS|VITALS
	icon_state = "vrobe"
	item_state = "vrobe"
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL

/obj/item/clothing/head/roguetown/vampire
	name = "crown of darkness"
	icon_state = "vcrown"
	body_parts_covered = null
	slot_flags = ITEM_SLOT_HEAD
	dynamic_hair_suffix = null
	sellprice = 1000
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/roguetown/armor/chainmail/iron/vampire
	icon_state = "vunder"
	icon = 'icons/roguetown/clothing/shirts.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/shirts.dmi'
	name = "ancient chain shirt"
	desc = ""
	body_parts_covered = CHEST|GROIN|VITALS
	armor_class = 2

/obj/item/clothing/suit/roguetown/armor/plate/vampire
	slot_flags = ITEM_SLOT_ARMOR
	name = "ancient ceremonial plate"
	desc = ""
	body_parts_covered = CHEST|GROIN|VITALS
	icon_state = "vplate"
	item_state = "vplate"
	armor = list("melee" = 100, "bullet" = 100, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	prevent_crits = list(BCLASS_CUT, BCLASS_CHOP, BCLASS_BLUNT)
	nodismemsleeves = TRUE
	max_integrity = 500
	allowed_sex = list(MALE, FEMALE)
	var/do_sound = TRUE
	anvilrepair = /datum/skill/craft/armorsmithing
	smeltresult = /obj/item/ingot/steel
	equip_delay_self = 40
	armor_class = 3

/obj/item/clothing/shoes/roguetown/boots/armor/vampire
	name = "ancient ceremonial plated boots"
	desc = ""
	body_parts_covered = FEET
	icon_state = "vboots"
	item_state = "vboots"
	prevent_crits = list(BCLASS_CUT, BCLASS_CHOP, BCLASS_BLUNT)
	color = null
	blocksound = PLATEHIT
	armor = list("melee" = 100, "bullet" = 100, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)

/obj/item/clothing/head/roguetown/helmet/heavy/guard
	name = "ancient ceremonial helm"
	icon_state = "vhelmet"

/obj/item/clothing/gloves/roguetown/chain/vampire
	name = "ancient ceremonial gloves"
	icon_state = "vgloves"

/datum/antagonist/vampirelord/on_removal()
	if(!silent && owner.current)
		to_chat(owner.current,"<span class='danger'>I am no longer a [job_rank]!</span>")
	owner.special_role = null
	if(!isnull(batform))
		owner.current.RemoveSpell(batform)
		QDEL_NULL(batform)
	return ..()
/datum/antagonist/vampirelord/proc/add_objective(datum/objective/O)
	var/datum/objective/V = new O
	objectives += V

/datum/antagonist/vampirelord/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/vampirelord/proc/forge_vampirelord_objectives()
	var/list/primary = pick(list("1", "2"))
	var/list/secondary = pick(list("1", "2", "3"))
	switch(primary)
		if("1")
			var/datum/objective/vampirelord/conquer/T = new
			objectives += T
		if("2")
			var/datum/objective/vampirelord/ascend/T = new
			objectives += T
	switch(secondary)
		if("1")
			var/datum/objective/vampirelord/infiltrate/one/T = new
			objectives += T
		if("2")
			var/datum/objective/vampirelord/infiltrate/two/T = new
			objectives += T
		if("3")
			var/datum/objective/vampirelord/spread/T = new
			objectives += T
	var/datum/objective/vlordsurvive/survive = new
	objectives += survive

/datum/antagonist/vampirelord/greet()
	to_chat(owner.current, "<span class='userdanger'>I am ancient. I am the Land. And I am now awoken to these trespassers upon my domain.</span>")
	owner.announce_objectives()
	..()

/datum/antagonist/vampirelord/lesser/greet()
	to_chat(owner.current, "<span class='userdanger'>We are awakened from our slumber, Spawn of the feared Vampire Lord.</span>")
	owner.announce_objectives()

/datum/antagonist/vampirelord/proc/finalize_vampire()
	owner.current.forceMove(pick(GLOB.vlord_starts))
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/vampintro.ogg', 80, FALSE, pressure_affected = FALSE)
	..()

/datum/antagonist/vampirelord/proc/finalize_vampire_lesser()
	if(!sired)
		owner.current.forceMove(pick(GLOB.vspawn_starts))
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/vampintro.ogg', 80, FALSE, pressure_affected = FALSE)
	..()

/datum/antagonist/vampirelord/proc/vamp_look()
	var/mob/living/carbon/human/V = owner.current
	cache_skin = V.skin_tone
	cache_eyes = V.eye_color
	cache_hair = V.hair_color
	V.skin_tone = "c9d3de"
	V.hair_color = "181a1d"
	V.facial_hair_color = "181a1d"
	V.eye_color = "ff0000"
	V.update_body()
	V.update_hair()
	V.update_body_parts(redraw = TRUE)
	V.mob_biotypes = MOB_UNDEAD
	if(isspawn)
		V.vampire_disguise()

/datum/antagonist/vampirelord/on_life(mob/user)
	if(!user)
		return
	var/mob/living/carbon/human/H = user
	if(H.stat == DEAD)
		return
	if(H.advsetup)
		return
	if(!isspawn)
		vitae = mypool.current
	if(ascended)
		return
	if(world.time % 5)
		if(GLOB.tod != "night")
			if(isturf(H.loc))
				var/turf/T = H.loc
				if(T.can_see_sky())
					if(T.get_lumcount() > 0.15)
						if(!isspawn)
							to_chat(H, "<span class='warning'>Astrata spurns me! I must get out of her rays!</span>") // VLord is more punished for daylight excursions.
							sleep(100)
							var/turf/N = H.loc
							if(N.can_see_sky())
								if(N.get_lumcount() > 0.15)
									H.dust()
							to_chat(H, "<span class='warning'>That was too close. I must avoid the sun.</span>")
						else if (isspawn && !disguised)
							H.fire_act(1,5)
							handle_vitae(-10)

	if(H.on_fire)
		if(disguised)
			last_transform = world.time
			H.vampire_undisguise(src)
		H.freak_out()

	if(H.stat)
		if(istype(H.loc, /obj/structure/closet/crate/coffin))
			H.fully_heal()

	if(vitae > 0)
		H.blood_volume = BLOOD_VOLUME_MAXIMUM
		if(vitae < 200)
			if(disguised)
				to_chat(H, "<span class='warning'>My disguise fails!</span>")
				H.vampire_undisguise(src)
	handle_vitae(-1)

/datum/antagonist/vampirelord/proc/handle_vitae(change, tribute)
	var/tempcurrent = vitae
	if(!isspawn)
		mypool.update_pool(change)
	if(isspawn)
		if(change > 0)
			tempcurrent += change
			if(tempcurrent > vmax)
				tempcurrent = vmax // to prevent overflow
		if(change < 0)
			tempcurrent += change
			if(tempcurrent < 0)
				tempcurrent = 0 // to prevent excessive negative.
		vitae = tempcurrent
	if(tribute)
		mypool.update_pool(tribute)
	if(vitae <= 20)
		if(!starved)
			to_chat(owner, "<span class='userdanger'>I starve, my power dwindles! I am so weak!</span>")
			starved = TRUE
			for(var/S in MOBSTATS)
				owner.current.change_stat(S, -5)
	else
		if(starved)
			starved = FALSE
			for(var/S in MOBSTATS)
				owner.current.change_stat(S, 5)

/datum/antagonist/vampirelord/proc/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.vlord_starts))

/datum/antagonist/vampirelord/proc/grow_in_power()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	switch(vamplevel)
		if(0)
			vamplevel = 1
			batform = new
			owner.current.AddSpell(batform)
			for(var/obj/structure/vampire/portalmaker/S in world)
				S.unlocked = TRUE
			for(var/S in MOBSTATS)
				owner.current.change_stat(S, 2)
			for(var/obj/structure/vampire/bloodpool/B in world)
				B.nextlevel = VAMP_LEVEL_TWO
			to_chat(owner, "<font color='red'>I am refreshed and have grown stronger. The visage of the bat is once again available to me. I can also once again access my portals.</font>")
		if(1)
			vamplevel = 2
			owner.current.verbs |= /mob/living/carbon/human/proc/vamp_regenerate
			owner.current.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/bloodsteal)
			owner.current.AddSpell(new /obj/effect/proc_holder/spell/invoked/projectile/bloodlightning)
			owner.adjust_skillrank(/datum/skill/magic/blood, 3, TRUE)
			gas = new
			owner.current.AddSpell(gas)
			for(var/S in MOBSTATS)
				owner.current.change_stat(S, 2)
			for(var/obj/structure/vampire/bloodpool/B in world)
				B.nextlevel = VAMP_LEVEL_THREE
			to_chat(owner, "<font color='red'>My power is returning. I can once again access my spells. I have also regained usage of my mist form.</font>")
		if(2)
			vamplevel = 3
			for(var/obj/structure/vampire/necromanticbook/S in world)
				S.unlocked = TRUE
			owner.current.verbs |= /mob/living/carbon/human/proc/blood_strength
			owner.current.verbs |= /mob/living/carbon/human/proc/blood_celerity
			owner.current.RemoveSpell(/obj/effect/proc_holder/spell/targeted/transfix)
			owner.current.AddSpell(new /obj/effect/proc_holder/spell/targeted/transfix/master)
			for(var/S in MOBSTATS)
				owner.current.change_stat(S, 2)
			for(var/obj/structure/vampire/bloodpool/B in world)
				B.nextlevel = VAMP_LEVEL_FOUR
			to_chat(owner, "<font color='red'>My dominion over others minds and my own body returns to me. I am nearing perfection. The armies of the dead shall now answer my call.</font>")
		if(3)
			vamplevel = 4
			owner.current.visible_message("<font color='red'>[owner.current] is enveloped in dark crimson, a horrific sound echoing in the area. They are evolved.</font>","<font color='red'>I AM ANCIENT, I AM THE LAND. EVEN THE SUN BOWS TO ME.</font>")
			ascended = TRUE
			C.ascended = TRUE
			for(var/datum/mind/thrall in C.vampires)
				if(thrall.special_role == "Vampire Spawn")
					thrall.current.verbs |= /mob/living/carbon/human/proc/blood_strength
					thrall.current.verbs |= /mob/living/carbon/human/proc/blood_celerity
					thrall.current.verbs |= /mob/living/carbon/human/proc/vamp_regenerate
					for(var/S in MOBSTATS)
						thrall.current.change_stat(S, 2)
	return

// SPAWN
/datum/antagonist/vampirelord/lesser
	name = "Vampire Spawn"
	confess_lines = list("THE CRIMSON CALLS!", "MY MASTER COMMANDS", "THE SUN IS ENEMY!")
	isspawn = TRUE

/datum/antagonist/vampirelord/lesser/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.vlordspawn_starts))

// NEW VERBS
/mob/living/carbon/human/proc/demand_submission()
	set name = "Demand Submission"
	set category = "VAMPIRE"
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(istype(C))
		if(C.kingsubmit)
			to_chat(src, "I am already the Master of Enigma.")
			return
	for(var/mob/living/carbon/human/H in oview(1))
		if(SSticker.rulermob == H)
			H.receive_submission(src)

/mob/living/carbon/human/proc/receive_submission(var/mob/living/carbon/human/lord)
	if(stat)
		return
	switch(alert("Submit and Pledge Allegiance to Lord [lord.name]?",,"Yes","No"))
		if("Yes")
			var/datum/game_mode/chaosmode/C = SSticker.mode
			if(istype(C))
				if(!C.kingsubmit)
					C.kingsubmit = TRUE
		if("No")
			lord << "<span class='boldnotice'>They refuse!</span>"
			src << "<span class='boldnotice'>I refuse!</span>"

/mob/living/carbon/human/proc/vampire_telepathy()
	set name = "Telepathy"
	set category = "VAMPIRE"

	var/datum/game_mode/chaosmode/C = SSticker.mode
	var/msg = input("Send a message.", "Command") as text|null
	if(!msg)
		return
	for(var/datum/mind/V in C.vampires)
		to_chat(V, "<span class='boldnotice'>A message from [src.real_name]:[msg]</span>")
	for(var/datum/mind/D in C.deathknights)
		to_chat(D, "<span class='boldnotice'>A message from [src.real_name]:[msg]</span>")
	for(var/mob/dead/observer/rogue/arcaneeye/A in world)
		to_chat(A, "<span class='boldnotice'>A message from [src.real_name]:[msg]</span>")

/mob/living/carbon/human/proc/punish_spawn()
	set name = "Punish Minion"
	set category = "VAMPIRE"

	var/datum/game_mode/chaosmode/C = SSticker.mode
	var/list/mob/living/carbon/human/possible = list()
	for(var/datum/mind/V in C.vampires)
		if(V.special_role == "Vampire Spawn")
			possible |= V.current
	for(var/datum/mind/D in C.deathknights)
		possible |= D.current
	var/mob/living/carbon/human/choice = input(src, "Who to punish?", "PUNISHMENT") as anything in possible|null
	if(choice)
		var/punishmentlevels = list("Pause", "Pain", "Release")
		switch(input(src, "Severity?", "PUNISHMENT") as anything in punishmentlevels|null)
			if("Pain")
				to_chat(choice, "<span class='boldnotice'>You are wracked with pain as your master punishes you!</span>")
				choice.apply_damage(30, BRUTE)
				choice.emote_scream()
				playsound(choice, 'sound/misc/obey.ogg', 100, FALSE, pressure_affected = FALSE)
			if("Pause")
				to_chat(choice, "<span class='boldnotice'>Your body is frozen in place as your master punishes you!</span>")
				choice.Paralyze(300)
				choice.emote_scream()
				playsound(choice, 'sound/misc/obey.ogg', 100, FALSE, pressure_affected = FALSE)
			if("Release")
				to_chat(choice, "<span class='boldnotice'>You feel only darkness. Your master no longer has use of you.</span>")
				spawn(10 SECONDS)
					choice.emote_scream()
					choice.dust()
		visible_message("<span class='danger'>[src] reaches out, gripping [choice]'s soul, inflicting punishment!</span>")

/obj/structure/vampire/portal/Crossed(atom/movable/AM)
	. = ..()
	if(istype(AM, /mob/living))
		for(var/obj/effect/landmark/vteleport/dest in world)
			playsound(loc, 'sound/misc/portalenter.ogg', 100, FALSE, pressure_affected = FALSE)
			AM.forceMove(dest.loc)
			break

/obj/structure/vampire/portal/sending/Crossed(atom/movable/AM)
	if(istype(AM, /mob/living))
		for(var/obj/effect/landmark/vteleportsenddest/V in world)
			AM.forceMove(V.loc)

/obj/structure/vampire/portal/sending/Destroy()
	for(var/obj/effect/landmark/vteleportsenddest/V in world)
		qdel(V)
	for(var/obj/structure/vampire/portalmaker/P in world)
		P.sending =  FALSE
	..()

/obj/structure/vampire/portalmaker/proc/create_portal_return(aname,duration)
	for(var/obj/effect/landmark/vteleportdestination/Vamp in world)
		if(Vamp.amuletname == aname)
			var/obj/structure/vampire/portal/P = new(Vamp.loc)
			P.duration = duration
			P.spawntime = world.time
			P.visible_message("<span class='boldnotice'>A sickening tear is heard as a sinister portal emerges.</span>")
		qdel(Vamp)

/obj/structure/vampire/portalmaker/proc/create_portal(choice,duration)
	sending = TRUE
	for(var/obj/effect/landmark/vteleportsending/S in world)
		var/obj/structure/vampire/portal/sending/P = new(S.loc)
		P.visible_message("<span class='boldnotice'>A sickening tear is heard as a sinister portal emerges.</span>")

/obj/structure/vampire/portal/Initialize()
	. = ..()
	set_light(3, 20, LIGHT_COLOR_BLOOD_MAGIC)
	playsound(loc, 'sound/misc/portalopen.ogg', 100, FALSE, pressure_affected = FALSE)
	sleep(600)
	visible_message("<span class='boldnotice'>[src] shudders before rapidly closing.</span>")
	qdel(src)

/obj/structure/vampire/portal/sending/Destroy()
	for(var/obj/structure/vampire/portalmaker/PM in world)
		PM.sending = FALSE
	. = ..()

/obj/structure/vampire/bloodpool/Initialize()
	. = ..()
	set_light(3, 20, LIGHT_COLOR_BLOOD_MAGIC)

/obj/structure/vampire/bloodpool/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='boldnotice'>Blood level: [current]</span>")

/obj/structure/vampire/bloodpool/attack_hand(mob/living/user)
	var/datum/antagonist/vampirelord/lord = user.mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(user.mind.special_role != "Vampire Lord")
		return
	var/choice = input(user,"What to do?", "ROGUETOWN") as anything in useoptions|null
	switch(choice)
		if("Grow Power")
			if(lord.vamplevel == 4)
				to_chat(user, "I'm already max level!")
				return
			if(alert(user, "Increase vampire level? Cost:[nextlevel]","","Yes","No") == "Yes")
				if(!check_withdraw(-nextlevel))
					to_chat(user, "I don't have enough vitae!")
					return
				if(do_after(user, 100))
					lord.handle_vitae(-nextlevel)
					lord.grow_in_power()
					user.playsound_local(get_turf(src), 'sound/misc/batsound.ogg', 100, FALSE, pressure_affected = FALSE)
		if("Shape Amulet")
			if(alert(user, "Craft a new amulet Cost:500","","Yes","No") == "Yes")
				if(!check_withdraw(-500))
					to_chat(user, "I don't have enough vitae!")
					return
				if(do_after(user, 100))
					lord.handle_vitae(-500)
					var/naming = input(user, "Select a name for the amulet.", "ROGUETOWN") as text|null
					var/obj/item/clothing/neck/roguetown/portalamulet/P = new(src.loc)
					if(naming)
						P.name = naming
					user.playsound_local(get_turf(src), 'sound/misc/vcraft.ogg', 100, FALSE, pressure_affected = FALSE)
		if("Shape Armor")
			if(alert(user, "Craft a new set of armor? Cost:1500","","Yes","No") == "Yes")
				if(!check_withdraw(-1500))
					to_chat(user, "I don't have enough vitae!")
					return
				if(do_after(user, 100))
					lord.handle_vitae(-1500)
					var/list/armorpieces = list(/obj/item/clothing/under/roguetown/platelegs/vampire, /obj/item/clothing/suit/roguetown/armor/chainmail/iron/vampire, /obj/item/clothing/suit/roguetown/armor/chainmail/iron/vampire, /obj/item/clothing/shoes/roguetown/boots/armor/vampire, /obj/item/clothing/head/roguetown/helmet/heavy/guard)
					for(var/obj/item/A in armorpieces)
						new A(src.loc)
				user.playsound_local(get_turf(src), 'sound/misc/vcraft.ogg', 100, FALSE, pressure_affected = FALSE)

/obj/structure/vampire/bloodpool/proc/update_pool(change)
	var/datum/game_mode/chaosmode/C = SSticker.mode
	var/tempmax = 8000
	if(istype(C))
		for(var/datum/mind/V in C.vampires)
			if(V.special_role == "vampirespawn")
				tempmax += 4000
		if(maximum != tempmax)
			maximum = tempmax
			if(current > maximum)
				current = maximum
	if(debug)
		maximum = 999999
		current = 999999
	if(change)
		current += change

/obj/structure/vampire/bloodpool/proc/check_withdraw(change)
	if(change < 0)
		if(abs(change) > current)
			return FALSE
		return TRUE

/obj/structure/vampire/portalmaker/attack_hand(mob/living/user)
	var/list/possibleportals = list()
	var/list/sendpossibleportals = list()
	var/datum/antagonist/vampirelord/lord = user.mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(user.mind.special_role != "Vampire Lord")
		return
	if(!lord.mypool.check_withdraw(-1000))
		to_chat(user, "This costs 1000 vitae, I lack that.")
		return
	if(!unlocked)
		to_chat(user, "I've yet to regain this aspect of my power!")
		return
	var/list/choices = list("Return", "Sending", "CANCEL")
	var/inputportal = input(user, "Which type of portal?", "Portal Type") as anything in choices
	switch(inputportal)
		if("Return")
			for(var/obj/item/clothing/neck/roguetown/portalamulet/P in world)
				possibleportals += P
			var/atom/choice = input(user, "Choose an area to open the portal", "Choices") as null|anything in possibleportals
			if(!choice)
				return
			user.visible_message("[user] begins to summon a portal.", "I begin to summon a portal.")
			if(do_after(user, 30))
				lord.handle_vitae(-1000)
				if(istype(choice, /obj/item/clothing/neck/roguetown/portalamulet))
					var/obj/item/clothing/neck/roguetown/portalamulet/A = choice
					A.uses -= 1
					var/obj/effect/landmark/vteleportdestination/VR = new(A.loc)
					VR.amuletname = A.name
					create_portal_return(A.name, 3000)
					user.playsound_local(get_turf(src), 'sound/misc/portalactivate.ogg', 100, FALSE, pressure_affected = FALSE)
					if(A.uses <= 0)
						A.visible_message("[A] shatters!")
						qdel(A)
		if("Sending")
			if(sending)
				to_chat(user, "A portal is already active!")
				return
			for(var/obj/item/clothing/neck/roguetown/portalamulet/P in world)
				sendpossibleportals += P
			var/atom/choice = input(user, "Choose an area to open the portal to", "Choices") as null|anything in sendpossibleportals
			if(!choice)
				return
			user.visible_message("[user] begins to summon a portal.", "I begin to summon a portal.")
			if(do_after(user, 30))
				lord.handle_vitae(-1000)
				if(istype(choice, /obj/item/clothing/neck/roguetown/portalamulet))
					var/obj/item/clothing/neck/roguetown/portalamulet/A = choice
					A.uses -= 1
					var/turf/G = get_turf(A)
					new /obj/effect/landmark/vteleportsenddest(G.loc)
					if(A.uses <= 0)
						A.visible_message("[A] shatters!")
						qdel(A)
					create_portal()
					user.playsound_local(get_turf(src), 'sound/misc/portalactivate.ogg', 100, FALSE, pressure_affected = FALSE)
		if("CANCEL")
			return
/* DISABLED FOR NOW
/obj/item/clothing/neck/roguetown/portalamulet/attack_self(mob/user)
	. = ..()
	if(alert(user, "Create a portal?", "PORTAL GEM", "Yes", "No") == "Yes")
		uses -= 1
		var/obj/effect/landmark/vteleportdestination/Vamp = new(loc)
		Vamp.amuletname = name
		for(var/obj/structure/vampire/portalmaker/P in world)
			P.create_portal_return(name, 3000)
		user.playsound_local(get_turf(src), 'sound/misc/portalactivate.ogg', 100, FALSE, pressure_affected = FALSE)
		if(uses <= 0)
			visible_message("[src] shatters!")
			qdel(src)
*/
/obj/structure/vampire/scryingorb/attack_hand(mob/living/carbon/human/user)
	if(user.mind.special_role == "Vampire Lord")
		user.visible_message("<font color='red'>[user]'s eyes turn dark red, as they channel the [src]</font>", "<font color='red'>I begin to channel my consciousness into a Predator's Eye.</font>")
		if(do_after(user, 60))
			user.scry(can_reenter_corpse = 1, force_respawn = FALSE)
	if(user.mind.special_role == "Vampire Spawn")
		to_chat(user, "I don't have the power to use this!")

/obj/structure/vampire/necromanticbook/attack_hand(mob/living/carbon/human/user)
	var/datum/antagonist/vampirelord/lord = user.mind.has_antag_datum(/datum/antagonist/vampirelord)
	if(user.mind.special_role == "Vampire Lord")
		if(!unlocked)
			to_chat(user, "I have yet to regain this aspect of my power!")
			return
		var/choice = input(user,"What to do?", "ROGUETOWN") as anything in useoptions|null
		switch(choice)
			if("Create Death Knight")
				if(alert(user, "Create a Death Knight? Cost:5000","","Yes","No") == "Yes")
					if(!lord.mypool.check_withdraw(-5000))
						to_chat(user, "I don't have enough vitae!")
						return
					if(do_after(user, 100))
						to_chat(user, "I have summoned a knight from the underworld. I need only wait for them to materialize.")
						var/datum/game_mode/chaosmode/C = SSticker.mode
						C.deathknightspawn = TRUE
						for(var/mob/dead/observer/D in GLOB.player_list)
							D.death_knight_spawn()
						for(var/mob/living/carbon/spirit/D in GLOB.player_list)
							D.death_knight_spawn()
				user.playsound_local(get_turf(src), 'sound/misc/vcraft.ogg', 100, FALSE, pressure_affected = FALSE)
			if("Steal the Sun")
				if(sunstolen)
					to_chat(user, "The sun is already stolen!")
					return
				if(GLOB.tod == "night")
					to_chat(user, "It's already night!")
					return
				if(alert(user, "Force Enigma into Night? Cost:5000","","Yes","No") == "Yes")
					if(!lord.mypool.check_withdraw(-2500))
						to_chat(user, "I don't have enough vitae!")
						return
					if(do_after(user, 100))
						GLOB.todoverride = "night"
						sunstolen = TRUE
						settod()
						spawn(6000)
							GLOB.todoverride = null
							sunstolen = FALSE
						priority_announce("The Sun is torn from the sky!", "Terrible Omen", 'sound/misc/astratascream.ogg')
						addomen("sunsteal")
						for(var/mob/living/carbon/human/W in world)
							var/datum/patrongods/patron = W.client.prefs.selected_patron
							if(patron.name == "Astrata")
								if(!W.mind.antag_datums)
									to_chat(W, "<span class='userdanger'>You feel the pain of your Patron!</span>")
									W.emote_scream()

	if(user.mind.special_role == "Vampire Spawn")
		to_chat(user, "I don't have the power to use this!")

/mob/proc/death_knight_spawn()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	SEND_SOUND(src, sound('sound/misc/notice (2).ogg'))
	if(alert(src, "A Vampire Lord is summoning you from the Underworld.", "Be Risen?", "Yes", "No") == "Yes")
		if(!C.deathknightspawn)
			to_chat(src, "<span class='warning'>Another soul was chosen.</span>")
		returntolobby()

// DEATH KNIGHT ANTAG
/datum/antagonist/skeleton/knight
	name = "Death Knight"
	increase_votepwr = FALSE

/datum/antagonist/skeleton/knight/on_gain()
	. = ..()
	owner.current.verbs |= /mob/living/carbon/human/proc/vampire_telepathy
	add_objective(/datum/objective/vlordserve)
	greet()

/datum/antagonist/skeleton/knight/greet()
	to_chat(owner.current, "<span class='userdanger'>I am returned to serve. I will obey, so that I may return to rest.</span>")
	owner.announce_objectives()
	..()

/datum/antagonist/skeleton/knight/proc/add_objective(datum/objective/O)
	var/datum/objective/V = new O
	objectives += V

/datum/antagonist/skeleton/knight/proc/remove_objective(datum/objective/O)
	objectives -= O

/datum/antagonist/skeleton/knight/roundend_report()
	var/traitorwin = TRUE

	printplayer(owner)

	var/count = 0
	if(objectives.len)//If the traitor had no objectives, don't need to process this.
		for(var/datum/objective/objective in objectives)
			objective.update_explanation_text()
			if(objective.check_completion())
				to_chat(owner, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='greentext'>TRIUMPH!</span>")
			else
				to_chat(owner, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='redtext'>Failure.</span>")
				traitorwin = FALSE
			count += objective.triumph_count
	var/special_role_text = lowertext(name)
	if(traitorwin)
		if(count)
			if(owner)
				owner.adjust_triumphs(count)
		to_chat(world, "<span class='greentext'>The [special_role_text] has TRIUMPHED!</span>")
		if(owner?.current)
			owner.current.playsound_local(get_turf(owner.current), 'sound/misc/triumph.ogg', 100, FALSE, pressure_affected = FALSE)
	else
		to_chat(world, "<span class='redtext'>The [special_role_text] has FAILED!</span>")
		if(owner?.current)
			owner.current.playsound_local(get_turf(owner.current), 'sound/misc/fail.ogg', 100, FALSE, pressure_affected = FALSE)
// OBJECTIVES STORED HERE TEMPORARILY FOR EASE OF REFERENCE

/datum/objective/vampirelord/conquer
	name = "conquer"
	explanation_text = "Make the Ruler of Enigma bow to my will."
	team_explanation_text = ""
	triumph_count = 5

/datum/objective/vampirelord/conquer/check_completion()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(istype(C))
		if(C.kingsubmit)
			return TRUE

/datum/objective/vampirelord/ascend
	name = "sun"
	explanation_text = "Astrata has spurned me long enough. I must conquer the Sun."
	team_explanation_text = ""
	triumph_count = 5

/datum/objective/vampirelord/ascend/check_completion()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(C.ascended)
		return TRUE

/datum/objective/vampirelord/infiltrate/one
	name = "infiltrate1"
	explanation_text = "Make a member of the Church my spawn."
	triumph_count = 5

/datum/objective/vampirelord/infiltrate/one/check_completion()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	var/list/churchjobs = list("Priest", "Priestess", "Cleric", "Acolyte", "Churchling", "Crusader")
	for(var/datum/mind/V in C.vampires)
		if(V.current.job in churchjobs)
			return TRUE

/datum/objective/vampirelord/infiltrate/two
	name = "infiltrate2"
	explanation_text = "Make a member of the Nobility my spawn."
	triumph_count = 5

/datum/objective/vampirelord/infiltrate/two/check_completion()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	var/list/noblejobs = list("King", "Queen", "Prince", "Princess", "Hand", "Steward")
	for(var/datum/mind/V in C.vampires)
		if(V.current.job in noblejobs)
			return TRUE

/datum/objective/vampirelord/spread
	name = "spread"
	explanation_text = "Have 10 vampire spawn."
	triumph_count = 5

/datum/objective/vampirelord/spread/check_completion()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(C.vampires.len >= 10)
		return TRUE

/datum/objective/vampirelord/stock
	name = "stock"
	explanation_text = "Have a crimson crucible with 30000 vitae."
	triumph_count = 1

/datum/objective/vlordsurvive
	name = "survive"
	explanation_text = "I am eternal. I must ensure the foolish mortals don't destroy me."
	triumph_count = 3

/datum/objective/vlordsurvive/check_completion()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(!C.vlord.stat)
		return TRUE

/datum/objective/vlordserve
	name = "serve"
	explanation_text = "I must serve my master, and ensure that they triumph."
	triumph_count = 3

/datum/objective/vlordserve/check_completion()
	var/datum/game_mode/chaosmode/C = SSticker.mode
	if(!C.vlord.stat)
		return TRUE

/datum/antagonist/vampirelord/roundend_report()
	var/traitorwin = TRUE

	printplayer(owner)

	var/count = 0
	if(isspawn) // don't need to spam up the chat with all spawn
		if(objectives.len)//If the traitor had no objectives, don't need to process this.
			for(var/datum/objective/objective in objectives)
				objective.update_explanation_text()
				if(objective.check_completion())
					to_chat(owner, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='greentext'>TRIUMPH!</span>")
				else
					to_chat(owner, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='redtext'>Failure.</span>")
					traitorwin = FALSE
				count += objective.triumph_count
	else
		if(objectives.len)//If the traitor had no objectives, don't need to process this.
			for(var/datum/objective/objective in objectives)
				objective.update_explanation_text()
				if(objective.check_completion())
					to_chat(world, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='greentext'>TRIUMPH!</span>")
				else
					to_chat(world, "<B>Goal #[count]</B>: [objective.explanation_text] <span class='redtext'>Failure.</span>")
					traitorwin = FALSE
				count += objective.triumph_count

	var/special_role_text = lowertext(name)
	if(traitorwin)
		if(count)
			if(owner)
				owner.adjust_triumphs(count)
		to_chat(world, "<span class='greentext'>The [special_role_text] has TRIUMPHED!</span>")
		if(owner?.current)
			owner.current.playsound_local(get_turf(owner.current), 'sound/misc/triumph.ogg', 100, FALSE, pressure_affected = FALSE)
	else
		to_chat(world, "<span class='redtext'>The [special_role_text] has FAILED!</span>")
		if(owner?.current)
			owner.current.playsound_local(get_turf(owner.current), 'sound/misc/fail.ogg', 100, FALSE, pressure_affected = FALSE)

// NEW OBJECTS/STRUCTURES
/obj/item/clothing/neck/roguetown/portalamulet
	name = "Gate Amulet"
	icon_state = "bloodtooth"
	icon = 'icons/roguetown/clothing/neck.dmi'
	var/uses = 3

/obj/structure/vampire
	icon = 'icons/roguetown/topadd/death/vamp-lord.dmi'
	var/unlocked = FALSE
	density = TRUE

/obj/structure/vampire/bloodpool
	name = "Crimson Crucible"
	icon_state = "vat"
	var/maximum = 8000
	var/current = 8000
	var/nextlevel = VAMP_LEVEL_ONE
	var/debug = FALSE
	var/list/useoptions = list("Grow Power", "Shape Amulet", "Shape Armor")

/obj/structure/vampire/scryingorb // Method of spying on the town
	name = "Eye of Night"
	icon_state = "scrying"

/obj/structure/vampire/necromanticbook // Used to summon undead to attack town/defend manor.
	name = "Tome of Souls"
	icon_state = "tome"
	var/list/useoptions = list("Create Death Knight", "Steal the Sun")
	var/sunstolen = FALSE

/obj/structure/vampire/portalmaker
	name = "Rift Gate"
	icon_state = "obelisk"
	var/sending = FALSE

/obj/structure/vampire/portal
	name = "Eerie Portal"
	icon_state = "portal"
	var/duration = 999
	var/spawntime = null
	density = 0

/obj/structure/vampire/portal/sending
	name = "Eerie Portal"
	icon_state = "portal"
	var/duration = 999
	var/spawntime = null
	var/turf/destloc
// LANDMARKS

/obj/effect/landmark/start/vampirelord
	name = "Vampire Lord"
	icon_state = "arrow"
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/vampirelord/Initialize()
	..()
	GLOB.vlord_starts += loc

/obj/effect/landmark/start/vampirespawn
	name = "Vampire Spawn"
	icon_state = "arrow"
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/vampireknight
	name = "Death Knight"
	icon_state = "arrow"
	jobspawn_override = list("Death Knight")
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/vampirespawn/Initialize()
	..()
	GLOB.vspawn_starts += loc

/obj/effect/landmark/vteleport
	name = "Teleport Destination"
	icon_state = "x2"

/obj/effect/landmark/vteleportsending
	name = "Teleport Sending"
	icon_state = "x2"

/obj/effect/landmark/vteleportdestination
	name = "Return Destination"
	icon_state = "x2"
	var/amuletname

/obj/effect/landmark/vteleportsenddest
	name = "Sending Destination"
	icon_state = "x2"
// SCRYING Since it has so many unique procs
/mob/dead/observer/rogue/arcaneeye
	sight = 0
	see_in_dark = 2
	var/next_gmove
	var/misting = 0
	var/mob/living/carbon/human/vampirelord = null
	icon_state = "arcaneeye"
	var/draw_icon = FALSE
	hud_type = /datum/hud/eye

/mob/proc/scry(can_reenter_corpse = 1, force_respawn = FALSE, drawskip)
	stop_sound_channel(CHANNEL_HEARTBEAT) //Stop heartbeat sounds because You Are A Ghost Now
	SSdroning.kill_rain(client)
	SSdroning.kill_loop(client)
	SSdroning.kill_droning(client)
	stop_sound_channel(CHANNEL_HEARTBEAT) //Stop heartbeat sounds because You Are A Ghost Now
	var/mob/dead/observer/rogue/arcaneeye/eye = new(src)	// Transfer safety to observer spawning proc.
	SStgui.on_transfer(src, eye) // Transfer NanoUIs.
	eye.can_reenter_corpse = can_reenter_corpse
	eye.vampirelord = src
	eye.ghostize_time = world.time
	eye.key = key
	return eye

/mob/dead/observer/rogue/arcaneeye/proc/scry_tele()
	set category = "Arcane Eye"
	set name = "Teleport"
	set desc= "Teleport to a location"
	set hidden = 0

	if(!isobserver(usr))
		to_chat(usr, "<span class='warning'>You're not an Eye!</span>")
		return
	var/list/filtered = list()
	for(var/V in GLOB.sortedAreas)
		var/area/A = V
		if(!A.hidden)
			filtered += A
	var/area/thearea  = input("Area to jump to", "ROGUETOWN") as null|anything in filtered

	if(!thearea)
		return

	var/list/L = list()
	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T

	if(!L || !L.len)
		to_chat(usr, "<span class='warning'>No area available.</span>")
		return

	usr.forceMove(pick(L))
	update_parallax_contents()

/mob/dead/observer/rogue/arcaneeye/Initialize()
	. = ..()
	set_invisibility(GLOB.observer_default_invisibility)
	verbs += list(
		/mob/dead/observer/rogue/arcaneeye/proc/scry_tele,
		/mob/dead/observer/rogue/arcaneeye/proc/cancel_scry,
		/mob/dead/observer/rogue/arcaneeye/proc/eye_down,
		/mob/dead/observer/rogue/arcaneeye/proc/eye_up,
		/mob/dead/observer/rogue/arcaneeye/proc/vampire_telepathy)
	testing("BEGIN LOC [loc]")
	name = "Arcane Eye"
	grant_all_languages()

/mob/dead/observer/rogue/arcaneeye/proc/cancel_scry()
	set category = "Arcane Eye"
	set name = "Cancel Eye"
	set desc= "Return to Body"

	if(vampirelord)
		vampirelord.ckey = ckey
		qdel(src)
	else
		to_chat(src, "My body has been destroyed! I'm trapped!")

/mob/dead/observer/rogue/arcaneeye/Crossed(mob/living/L)
	if(istype(L, /mob/living/carbon/human))
		var/mob/living/carbon/human/V = L
		var/holyskill = V.mind.get_skill_level(/datum/skill/magic/holy)
		var/magicskill = V.mind.get_skill_level(/datum/skill/magic/arcane)
		if(magicskill >= 2)
			to_chat(V, "<font color='red'>An ancient and unusual magic looms in the air around you.</font>")
			return
		if(holyskill >= 2)
			to_chat(V, "<font color='red'>An ancient and unholy magic looms in the air around you.</font>")
			return
		if(prob(20))
			to_chat(V, "<font color='red'>You feel like someone is watching you, or something.</font>")
			return

/mob/dead/observer/rogue/arcaneeye/proc/vampire_telepathy()
	set name = "Telepathy"
	set category = "Arcane Eye"

	var/datum/game_mode/chaosmode/C = SSticker.mode
	var/msg = input("Send a message.", "Command") as text|null
	if(!msg)
		return
	for(var/datum/mind/V in C.vampires)
		to_chat(V, "<span class='boldnotice'>A message from [src.real_name]:[msg]</span>")
	for(var/datum/mind/D in C.deathknights)
		to_chat(D, "<span class='boldnotice'>A message from [src.real_name]:[msg]</span>")
	for(var/mob/dead/observer/rogue/arcaneeye/A in world)
		to_chat(A, "<span class='boldnotice'>A message from [src.real_name]:[msg]</span>")

/mob/dead/observer/rogue/arcaneeye/proc/eye_up()
	set category = "Arcane Eye"
	set name = "Move Up"

	if(zMove(UP, TRUE))
		to_chat(src, "<span class='notice'>I move upwards.</span>")

/mob/dead/observer/rogue/arcaneeye/proc/eye_down()
	set category = "Arcane Eye"
	set name = "Move Down"

	if(zMove(DOWN, TRUE))
		to_chat(src, "<span class='notice'>I move down.</span>")

/mob/dead/observer/rogue/arcaneeye/Move(NewLoc, direct)
	if(world.time < next_gmove)
		return
	next_gmove = world.time + 3

	if(updatedir)
		setDir(direct)//only update dir if we actually need it, so overlays won't spin on base sprites that don't have directions of their own
	var/oldloc = loc

	if(NewLoc)
		var/NewLocTurf = get_turf(NewLoc)
		if(istype(NewLocTurf, /turf/closed/mineral/rogue/bedrock)) // prevent going out of bounds.
			return
		forceMove(NewLoc)
		update_parallax_contents()
	else
		forceMove(get_turf(src))  //Get out of closets and such as a ghost
		if((direct & NORTH) && y < world.maxy)
			y++
		else if((direct & SOUTH) && y > 1)
			y--
		if((direct & EAST) && x < world.maxx)
			x++
		else if((direct & WEST) && x > 1)
			x--

	Moved(oldloc, direct)

// Spells
/obj/effect/proc_holder/spell/targeted/transfix
	name = "Transfix"
	overlay_state = "transfix"
	releasedrain = 100
	chargedrain = 0
	chargetime = 0
	range = 15
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/blood
	antimagic_allowed = TRUE
	charge_max = 5 SECONDS
	include_user = 0
	max_targets = 1

/obj/effect/proc_holder/spell/targeted/transfix/cast(list/targets, mob/user = usr)
	var/bloodskill = user.mind.get_skill_level(/datum/skill/magic/blood)
	var/bloodroll = roll("[bloodskill]d8")
	for(var/mob/living/carbon/human/L in targets)
		var/datum/antagonist/vampirelord/VD = L.mind.has_antag_datum(/datum/antagonist/vampirelord)
		var/willpower = round(L.STAINT / 3)
		var/willroll = roll("[willpower]d6")
		if(VD)
			return
		if(L.cmode)
			willroll += 10
		if(bloodroll >= willroll)
			to_chat(L, "You feel like a curtain is coming over your mind.")
			to_chat(user, "Their mind gives way, they will soon be asleep.")
			sleep(50)
			L.Sleeping(300)
		if(willroll >= bloodroll)
			to_chat(user, "I fail to ensnare their mind.")
			if(willroll - bloodroll >= 3)
				to_chat(L, "I feel like something is messing with my head.")
				var/holyskill = user.mind.get_skill_level(/datum/skill/magic/holy)
				var/arcaneskill = user.mind.get_skill_level(/datum/skill/magic/arcane)
				if(holyskill + arcaneskill >= 3)
					to_chat(L, "I feel like the magic came from [user]")

/obj/effect/proc_holder/spell/targeted/transfix/master
	name = "Subjugate"
	overlay_state = "transfixmaster"
	releasedrain = 200
	chargedrain = 0
	chargetime = 0
	range = 15
	warnie = "sydwarning"
	movement_interrupt = FALSE
	chargedloop = null
	invocation_type = "shout"
	associated_skill = /datum/skill/magic/blood
	antimagic_allowed = TRUE
	charge_max = 5 SECONDS
	include_user = 0
	max_targets = 0

/obj/effect/proc_holder/spell/targeted/transfix/master/cast(list/targets, mob/user = usr)
	var/bloodskill = user.mind.get_skill_level(/datum/skill/magic/blood)
	var/bloodroll = roll("[bloodskill]d10")
	user.visible_message("<font color='red'>[user]'s eyes glow a ghastly red as they project their will outwards!</font>")
	for(var/mob/living/carbon/human/L in targets)
		var/datum/antagonist/vampirelord/VD = L.mind.has_antag_datum(/datum/antagonist/vampirelord)
		var/willpower = round(L.STAINT / 3)
		var/willroll = roll("[willpower]d6")
		if(VD)
			return
		if(L.cmode)
			willroll += 15
		if(bloodroll >= willroll)
			to_chat(L, "<font color='purple'>You feel like a curtain is coming over your mind.</font>")
			sleep(50)
			L.Sleeping(300)

