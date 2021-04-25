


///////////////////// LANDMARK CORPSE ///////




//These are meant for spawning on maps, namely Away Missions.

//If someone can do this in a neater way, be my guest-Kor

//To do: Allow corpses to appear mangled, bloody, etc. Allow customizing the bodies appearance (they're all bald and white right now).

/obj/effect/landmark/corpsespawner
	name = "Unknown"
	var/mobname = "Unknown"  //Unused now but it'd fuck up maps to remove it now
	var/corpseuniform = null //Set this to an object path to have the slot filled with said object on the corpse.
	var/corpsesuit = null
	var/corpseshoes = null
	var/corpsegloves = null
	var/corpseradio = null
	var/corpseglasses = null
	var/corpsemask = null
	var/corpsehelmet = null
	var/corpsebelt = null
	var/corpsepocket1 = null
	var/corpsepocket2 = null
	var/corpseback = null
	var/corpseid = 0     //Just set to 1 if you want them to have an ID
	var/corpseidjob = null // Needs to be in quotes, such as "Clown" or "Chef." This just determines what the ID reads as, not their access
	var/corpseidaccess = null //This is for access. See access.dm for which jobs give what access. Use CAPTAIN if you want it to be all access.
	var/corpseidicon = null //For setting it to be a gold, silver, centcomm etc ID
	var/xenovictim = TRUE //whether this person was infected and killed by xenos


/obj/effect/landmark/corpsespawner/Initialize()
	. = ..()
	var/mob/living/carbon/human/M = new /mob/living/carbon/human(loc)
	GLOB.round_statistics.total_humans_created-- //corpses don't count
	SSblackbox.record_feedback("tally", "round_statistics", -1, "total_humans_created")

	M.real_name = name
	M.death(silent = TRUE) //Kills the new mob
	M.timeofdeath = -CONFIG_GET(number/revive_grace_period)
	INVOKE_ASYNC(src, .proc/equip_items_to_mob, M)
	if(xenovictim)
		// no damage because limb updates are expensive
		var/datum/internal_organ/O
		var/i
		for(i in list("heart","lungs"))
			O = M.internal_organs_by_name[i]
			M.internal_organs_by_name -= i
			M.internal_organs -= O
		M.chestburst = 2
		ADD_TRAIT(M, TRAIT_PSY_DRAINED, TRAIT_PSY_DRAINED)
		M.update_burst()
		//buckle to nest
		var/obj/structure/bed/nest/victim_nest = locate() in get_turf(src)
		if(victim_nest)
			victim_nest.buckle_mob(M, silent = TRUE)
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/corpsespawner/proc/equip_items_to_mob(mob/living/carbon/human/corpse)
	if(corpseuniform)
		corpse.equip_to_slot_or_del(new corpseuniform(corpse), SLOT_W_UNIFORM)
	if(corpsesuit)
		corpse.equip_to_slot_or_del(new corpsesuit(corpse), SLOT_WEAR_SUIT)
	if(corpseshoes)
		corpse.equip_to_slot_or_del(new corpseshoes(corpse), SLOT_SHOES)
	if(corpsegloves)
		corpse.equip_to_slot_or_del(new corpsegloves(corpse), SLOT_GLOVES)
	if(corpseradio)
		corpse.equip_to_slot_or_del(new corpseradio(corpse), SLOT_EARS)
	if(corpseglasses)
		corpse.equip_to_slot_or_del(new corpseglasses(corpse), SLOT_GLASSES)
	if(corpsemask)
		corpse.equip_to_slot_or_del(new corpsemask(corpse), SLOT_WEAR_MASK)
	if(corpsehelmet)
		corpse.equip_to_slot_or_del(new corpsehelmet(corpse), SLOT_HEAD)
	if(corpsebelt)
		corpse.equip_to_slot_or_del(new corpsebelt(corpse), SLOT_BELT)
	if(corpsepocket1)
		corpse.equip_to_slot_or_del(new corpsepocket1(corpse), SLOT_R_STORE)
	if(corpsepocket2)
		corpse.equip_to_slot_or_del(new corpsepocket2(corpse), SLOT_L_STORE)
	if(corpseback)
		corpse.equip_to_slot_or_del(new corpseback(corpse), SLOT_BACK)
	if(corpseid)
		var/obj/item/card/id/newid = new(corpse)
		newid.name = "[corpse.real_name]'s ID Card"
		var/datum/job/jobdatum
		for(var/jobtype in typesof(/datum/job))
			var/datum/job/J = new jobtype
			if(J.title == corpseidaccess)
				jobdatum = J
				break
		if(corpseidicon)
			newid.icon_state = corpseidicon
		if(corpseidaccess)
			if(jobdatum)
				newid.access = jobdatum.get_access()
			else
				newid.access = list()
		if(corpseidjob)
			newid.assignment = corpseidjob
		newid.registered_name = corpse.real_name
		corpse.equip_to_slot_or_del(newid, SLOT_WEAR_ID)

// I'll work on making a list of corpses people request for maps, or that I think will be commonly used. Syndicate operatives for example.

/obj/effect/landmark/corpsespawner/syndicatesoldier
	name = "Syndicate Operative"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsegloves = /obj/item/clothing/gloves/swat
	corpseradio = /obj/item/radio/headset
	corpsemask = /obj/item/clothing/mask/gas
	corpsehelmet = /obj/item/clothing/head/helmet/swat
	corpseback = /obj/item/storage/backpack
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"



/obj/effect/landmark/corpsespawner/syndicatecommando
	name = "Syndicate Commando"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/space/rig/syndi
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsegloves = /obj/item/clothing/gloves/swat
	corpseradio = /obj/item/radio/headset
	corpsemask = /obj/item/clothing/mask/gas/syndicate
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/syndi
	corpseback = /obj/item/tank/jetpack/oxygen
	corpsepocket1 = /obj/item/tank/emergency_oxygen
	corpseid = 1
	corpseidjob = "Operative"
	corpseidaccess = "Syndicate"



/obj/effect/landmark/corpsespawner/pirate
	name = "Pirate"
	corpseuniform = /obj/item/clothing/under/syndicate
	corpsesuit = /obj/item/clothing/suit/armor/vest
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsegloves = /obj/item/clothing/gloves/swat
	corpseradio = /obj/item/radio/headset
	corpsemask = /obj/item/clothing/mask/gas
	corpsehelmet = /obj/item/clothing/head/helmet/swat
	corpseback = /obj/item/storage/backpack



/obj/effect/landmark/corpsespawner/realpirate
	name = "Pirate"
	corpseuniform = /obj/item/clothing/under/pirate
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsehelmet = /obj/item/clothing/head/bandanna



/obj/effect/landmark/corpsespawner/realpirate/ranged
	name = "Pirate Gunner"
	corpsesuit = /obj/item/clothing/suit/pirate
	corpsehelmet = /obj/item/clothing/head/pirate




/obj/effect/landmark/corpsespawner/russian
	name = "Russian"
	corpseuniform = /obj/item/clothing/under/soviet
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsehelmet = /obj/item/clothing/head/bearpelt

/obj/effect/landmark/corpsespawner/russian/ranged
	corpsehelmet = /obj/item/clothing/head/ushanka

///////////Civilians//////////////////////

/obj/effect/landmark/corpsespawner/prisoner
	name = "Prisoner"
	corpseuniform = /obj/item/clothing/under/rank/prisoner
	corpseshoes = /obj/item/clothing/shoes/orange
	corpseid = 1
	corpseidjob = "Prisoner"


/obj/effect/landmark/corpsespawner/chef
	name = "Chef"
	corpseuniform = /obj/item/clothing/under/rank/chef
	corpsesuit = /obj/item/clothing/suit/chef/classic
	corpseshoes = /obj/item/clothing/shoes/black
	corpsehelmet = /obj/item/clothing/head/chefhat
	corpseback = /obj/item/storage/backpack
	corpseid = 1
	corpseidjob = "Chef"
//	corpseidaccess = "Syndicate"


/obj/effect/landmark/corpsespawner/doctor
	name = "Doctor"
	corpseuniform = /obj/item/clothing/under/colonist
	corpsesuit = /obj/item/clothing/suit/storage/labcoat
	corpseback = /obj/item/storage/backpack/corpsman
	corpsepocket1 = /obj/item/flashlight/pen
	corpseshoes = /obj/item/clothing/shoes/black
	corpseid = 1
	corpseidjob = "Medical Doctor"
//	corpseidaccess = "Medical Doctor"

/obj/effect/landmark/corpsespawner/engineer
	name = "Engineer"
	corpseuniform = /obj/item/clothing/under/colonist
	corpseback = /obj/item/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/orange
	corpsebelt = /obj/item/storage/belt/utility/full
	corpsegloves = /obj/item/clothing/gloves/yellow
	corpsehelmet = /obj/item/clothing/head/hardhat
	corpseid = 1
	corpseidjob = "Station Engineer"
//	corpseidaccess = "Station Engineer"

/obj/effect/landmark/corpsespawner/engineer/rig
	corpsesuit = /obj/item/clothing/suit/space/rig/engineering
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/engineering

/obj/effect/landmark/corpsespawner/clown
	name = "Clown"
	corpseuniform = /obj/item/clothing/under/rank/clown
	corpseshoes = /obj/item/clothing/shoes/clown_shoes
	corpsemask = /obj/item/clothing/mask/gas/clown_hat
	corpsepocket1 = /obj/item/toy/bikehorn
	corpseback = /obj/item/storage/backpack/clown
	corpseid = 1
	corpseidjob = "Clown"
//	corpseidaccess = "Clown"

/obj/effect/landmark/corpsespawner/scientist
	name = "Scientist"
	corpseuniform = /obj/item/clothing/under/marine/officer/researcher
	corpsesuit = /obj/item/clothing/suit/storage/labcoat
	corpseback = /obj/item/storage/backpack
	corpseshoes = /obj/item/clothing/shoes/white
	corpseid = 1
	corpseidjob = "Scientist"
//	corpseidaccess = "Scientist"

/obj/effect/landmark/corpsespawner/miner
	corpseuniform = /obj/item/clothing/under/colonist
	corpsegloves = /obj/item/clothing/gloves/black
	corpseback = /obj/item/storage/backpack/industrial
	corpseshoes = /obj/item/clothing/shoes/black
	corpseid = 1
	corpseidjob = "Shaft Miner"
//	corpseidaccess = "Shaft Miner"

/obj/effect/landmark/corpsespawner/miner/rig
	corpsesuit = /obj/item/clothing/suit/space/rig/mining
	corpsemask = /obj/item/clothing/mask/breath
	corpsehelmet = /obj/item/clothing/head/helmet/space/rig/mining

/obj/effect/landmark/corpsespawner/security
	corpseuniform = /obj/item/clothing/under/rank/security
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsesuit = /obj/item/clothing/suit/armor/vest/security

/obj/effect/landmark/corpsespawner/prison_security
	name = "Prison Guard"
	corpseuniform = /obj/item/clothing/under/rank/security
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsegloves = /obj/item/clothing/gloves/black
	corpsesuit = /obj/item/clothing/suit/armor/vest/security
	corpsehelmet = /obj/item/clothing/head/helmet
	corpseid = 1
	corpseidjob = "Prison Guard"


/obj/effect/landmark/corpsespawner/pmc
	name = "Unknown PMC"
	corpseuniform = /obj/item/clothing/under/marine/veteran/PMC
	corpseshoes = /obj/item/clothing/shoes/jackboots
	corpsesuit = /obj/item/clothing/suit/armor/vest/security
	corpseback = /obj/item/storage/backpack/satchel
	corpsebelt = /obj/item/storage/belt/gun/pistol/m4a3/vp70
	corpsegloves = /obj/item/clothing/gloves/marine/veteran/PMC
	corpsehelmet = /obj/item/clothing/head/helmet/marine/veteran/PMC
	corpsemask = /obj/item/clothing/mask/gas/PMC/damaged
	corpseradio = /obj/item/radio/headset/survivor
	corpsesuit = /obj/item/clothing/suit/storage/marine/veteran/PMC

/obj/effect/landmark/corpsespawner/colonist
	name = "Colonist"
	corpseuniform = /obj/item/clothing/under/colonist
	corpseshoes = /obj/item/clothing/shoes/black


/////////////////Officers//////////////////////

/obj/effect/landmark/corpsespawner/bridgeofficer
	name = "Staff Officer"
	corpseuniform = /obj/item/clothing/under/rank/centcom_officer
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseshoes = /obj/item/clothing/shoes/black
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpseid = 1
	corpseidjob = "Staff Officer"
	corpseidaccess = CAPTAIN

/obj/effect/landmark/corpsespawner/commander
	name = "Commander"
	corpseuniform = /obj/item/clothing/under/rank/centcom_commander
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseglasses = /obj/item/clothing/glasses/eyepatch
	corpsemask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	corpsehelmet = /obj/item/clothing/head/centhat
	corpsegloves = /obj/item/clothing/gloves/swat
	corpseshoes = /obj/item/clothing/shoes/swat
	corpsepocket1 = /obj/item/tool/lighter/zippo
	corpseid = 1
	corpseidjob = "Commander"
	corpseidaccess = CAPTAIN

/obj/effect/landmark/corpsespawner/PMC
	name = "Private Security Officer"
	corpseuniform = /obj/item/clothing/under/marine/veteran/PMC
	corpsesuit = /obj/item/clothing/suit/armor/bulletproof
	corpseglasses = /obj/item/clothing/glasses/sunglasses
	corpsemask = /obj/item/clothing/mask/gas
	corpsehelmet = /obj/item/clothing/head/helmet/marine/veteran/PMC
	corpsegloves = /obj/item/clothing/gloves/marine/veteran/PMC
	corpseshoes = /obj/item/clothing/shoes/veteran/PMC
	corpsepocket1 = /obj/item/tool/lighter/zippo
	corpseid = 1
	corpseidjob = "Private Security Officer"
	corpseidaccess = "101"
