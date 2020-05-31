/*

	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna2.dm, so you do not
	have to define any UI values for sprite accessories manually for hair and facial
	hair. Just add in new hair types and the game will naturally adapt.

	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/

/proc/init_sprite_accessory_subtypes(prototype, list/L, list/male, list/female,roundstart = FALSE)//Roundstart argument builds a specific list for roundstart parts where some parts may be locked
	if(!istype(L))
		L = list()
	if(!istype(male))
		male = list()
	if(!istype(female))
		female = list()

	for(var/path in typesof(prototype))
		if(path == prototype)
			continue
		if(roundstart)
			var/datum/sprite_accessory/P = path
			if(initial(P.locked))
				continue
		var/datum/sprite_accessory/D = new path()

		if(D.icon_state)
			L[D.name] = D
		else
			L += D.name

		switch(D.gender)
			if(MALE)
				male += D.name
			if(FEMALE)
				female += D.name
			else
				male += D.name
				female += D.name
	return L


/datum/sprite_accessory
	var/icon			// the icon file the accessory is located in
	var/icon_state		// the icon_state of the accessory
	var/preview_state	// a custom preview state for whatever reason
	var/name			// the preview name of the accessory
	var/gender = NEUTER // Determines if the accessory will be skipped or included in random hair generations
	var/locked = FALSE		//Is this part locked from roundstart selection? Used for parts that apply effects

	var/list/species_allowed = list("Human","Human Hero", "Synthetic", "Early Synthetics") // Restrict some styles to specific species
	var/do_colouration = TRUE	// Whether or not the accessory can be affected by colouration


/*
////////////////////////////
/  =--------------------=  /
/  == Hair Definitions ==  /
/  =--------------------=  /
////////////////////////////
*/

/datum/sprite_accessory/hair
	species_allowed = list("Human","Unathi","Tajara","Skrell","Vox","Machine","Synthetic","Early Synthetic")
	icon = 'icons/mob/Human_face.dmi'

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = "bald"

/datum/sprite_accessory/hair/milbuzzcut
	name = "Military Buzzcut"
	icon_state = "hair_milbuzzcut"
	gender = MALE

/datum/sprite_accessory/hair/milbun
	name = "Military Bun"
	icon_state = "hair_milbun"
	gender = FEMALE

// Non-humans from here on.

/datum/sprite_accessory/hair/icp_screen_pink
	name = "pink IPC screen"
	icon_state = "ipc_pink"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_red
	name = "red IPC screen"
	icon_state = "ipc_red"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_green
	name = "green IPC screen"
	icon_state = "ipc_green"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_blue
	name = "blue IPC screen"
	icon_state = "ipc_blue"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_breakout
	name = "breakout IPC screen"
	icon_state = "ipc_breakout"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_eight
	name = "eight IPC screen"
	icon_state = "ipc_eight"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_goggles
	name = "goggles IPC screen"
	icon_state = "ipc_goggles"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_heart
	name = "heart IPC screen"
	icon_state = "ipc_heart"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_monoeye
	name = "monoeye IPC screen"
	icon_state = "ipc_monoeye"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_nature
	name = "nature IPC screen"
	icon_state = "ipc_nature"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_orange
	name = "orange IPC screen"
	icon_state = "ipc_orange"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_purple
	name = "purple IPC screen"
	icon_state = "ipc_purple"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_shower
	name = "shower IPC screen"
	icon_state = "ipc_shower"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_static
	name = "static IPC screen"
	icon_state = "ipc_static"
	species_allowed = list("Machine")

/datum/sprite_accessory/hair/icp_screen_yellow
	name = "yellow IPC screen"
	icon_state = "ipc_yellow"
	species_allowed = list("Machine")

/*
///////////////////////////////////
/  =---------------------------=  /
/  == Facial Hair Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/facial_hair
	icon = 'icons/mob/Human_face.dmi'
	gender = MALE

/datum/sprite_accessory/facial_hair/shaved
	name = "Shaved"
	icon_state = "bald"
	gender = NEUTER
	species_allowed = list("Human","Unathi","Tajara","Skrell","Vox","Machine","Synthetic", "Early Synthetic")

/datum/sprite_accessory/facial_hair/watson
	name = "Watson Mustache"
	icon_state = "facial_watson"

/datum/sprite_accessory/facial_hair/hogan
	name = "Hulk Hogan Mustache"
	icon_state = "facial_hogan"

/datum/sprite_accessory/facial_hair/vandyke
	name = "Van Dyke Mustache"
	icon_state = "facial_vandyke"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Square Mustache"
	icon_state = "facial_chaplin"

/datum/sprite_accessory/facial_hair/selleck
	name = "Selleck Mustache"
	icon_state = "facial_selleck"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Neckbeard"
	icon_state = "facial_neckbeard"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Full Beard"
	icon_state = "facial_fullbeard"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Long Beard"
	icon_state = "facial_longbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Very Long Beard"
	icon_state = "facial_wise"

/datum/sprite_accessory/facial_hair/elvis
	name = "Elvis Sideburns"
	icon_state = "facial_elvis"

/datum/sprite_accessory/facial_hair/abe
	name = "Abraham Lincoln Beard"
	icon_state = "facial_abe"

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Chinstrap"
	icon_state = "facial_chin"

/datum/sprite_accessory/facial_hair/hip
	name = "Hipster Beard"
	icon_state = "facial_hip"

/datum/sprite_accessory/facial_hair/gt
	name = "Goatee"
	icon_state = "facial_gt"

/datum/sprite_accessory/facial_hair/jensen
	name = "Adam Jensen Beard"
	icon_state = "facial_jensen"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Dwarf Beard"
	icon_state = "facial_dwarf"

/datum/sprite_accessory/facial_hair/threeOclock
	name = "3 O'clock Shadow"
	icon_state = "facial_3oclock"

/datum/sprite_accessory/facial_hair/ficeOclock
	name = "5 O'clock Shadow"
	icon_state = "facial_5oclock"

/datum/sprite_accessory/facial_hair/fiveOclock_m
	name = "5 Oclock Moustache"
	icon_state = "facial_5oclockmoustache"

/datum/sprite_accessory/facial_hair/sevenOclock
	name = "7 O'clock Shadow"
	icon_state = "facial_7oclock"

/datum/sprite_accessory/facial_hair/soul_patch
	name = "Soul Patch"
	icon_state = "facial_soulpatch"

/*
///////////////////////////////////
/  =---------------------------=  /
/  == Alien Style Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/hair/una_spines_long
	name = "Long Unathi Spines"
	icon_state = "soghun_longspines"
	species_allowed = list("Unathi")

/datum/sprite_accessory/hair/una_spines_short
	name = "Short Unathi Spines"
	icon_state = "soghun_shortspines"
	species_allowed = list("Unathi")

/datum/sprite_accessory/hair/una_frills_long
	name = "Long Unathi Frills"
	icon_state = "soghun_longfrills"
	species_allowed = list("Unathi")

/datum/sprite_accessory/hair/una_frills_short
	name = "Short Unathi Frills"
	icon_state = "soghun_shortfrills"
	species_allowed = list("Unathi")

/datum/sprite_accessory/hair/una_horns
	name = "Unathi Horns"
	icon_state = "soghun_horns"
	species_allowed = list("Unathi")

/datum/sprite_accessory/hair/skr_tentacle_m
	name = "Skrell Male Tentacles"
	icon_state = "skrell_hair_m"
	species_allowed = list("Skrell")
	gender = MALE

/datum/sprite_accessory/hair/skr_tentacle_f
	name = "Skrell Female Tentacles"
	icon_state = "skrell_hair_f"
	species_allowed = list("Skrell")
	gender = FEMALE

/datum/sprite_accessory/hair/skr_gold_m
	name = "Gold plated Skrell Male Tentacles"
	icon_state = "skrell_goldhair_m"
	species_allowed = list("Skrell")
	gender = MALE

/datum/sprite_accessory/hair/skr_gold_f
	name = "Gold chained Skrell Female Tentacles"
	icon_state = "skrell_goldhair_f"
	species_allowed = list("Skrell")
	gender = FEMALE

/datum/sprite_accessory/hair/skr_clothtentacle_m
	name = "Cloth draped Skrell Male Tentacles"
	icon_state = "skrell_clothhair_m"
	species_allowed = list("Skrell")
	gender = MALE

/datum/sprite_accessory/hair/skr_clothtentacle_f
	name = "Cloth draped Skrell Female Tentacles"
	icon_state = "skrell_clothhair_f"
	species_allowed = list("Skrell")
	gender = FEMALE

/datum/sprite_accessory/hair/taj_ears
	name = "Tajaran Ears"
	icon_state = "ears_plain"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/taj_ears_clean
	name = "Tajara Clean"
	icon_state = "hair_clean"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/taj_ears_bangs
	name = "Tajara Bangs"
	icon_state = "hair_bangs"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/taj_ears_braid
	name = "Tajara Braid"
	icon_state = "hair_tbraid"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/taj_ears_shaggy
	name = "Tajara Shaggy"
	icon_state = "hair_shaggy"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/taj_ears_mohawk
	name = "Tajaran Mohawk"
	icon_state = "hair_mohawk"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/taj_ears_plait
	name = "Tajara Plait"
	icon_state = "hair_plait"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/taj_ears_straight
	name = "Tajara Straight"
	icon_state = "hair_straight"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/taj_ears_long
	name = "Tajara Long"
	icon_state = "hair_long"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/taj_ears_rattail
	name = "Tajara Rat Tail"
	icon_state = "hair_rattail"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/taj_ears_spiky
	name = "Tajara Spiky"
	icon_state = "hair_tajspiky"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/taj_ears_messy
	name = "Tajara Messy"
	icon_state = "hair_messy"
	species_allowed = list("Tajara")

/datum/sprite_accessory/hair/vox_quills_short
	name = "Short Vox Quills"
	icon_state = "vox_shortquills"
	species_allowed = list("Vox")


/datum/sprite_accessory/facial_hair/taj_sideburns
	name = "Tajara Sideburns"
	icon_state = "facial_mutton"
	species_allowed = list("Tajara")

/datum/sprite_accessory/facial_hair/taj_mutton
	name = "Tajara Mutton"
	icon_state = "facial_mutton"
	species_allowed = list("Tajara")

/datum/sprite_accessory/facial_hair/taj_pencilstache
	name = "Tajara Pencilstache"
	icon_state = "facial_pencilstache"
	species_allowed = list("Tajara")

/datum/sprite_accessory/facial_hair/taj_moustache
	name = "Tajara Moustache"
	icon_state = "facial_moustache"
	species_allowed = list("Tajara")

/datum/sprite_accessory/facial_hair/taj_goatee
	name = "Tajara Goatee"
	icon_state = "facial_goatee"
	species_allowed = list("Tajara")

/datum/sprite_accessory/facial_hair/taj_smallstache
	name = "Tajara Smallsatche"
	icon_state = "facial_smallstache"
	species_allowed = list("Tajara")

//skin styles - WIP
//going to have to re-integrate this with surgery
//let the icon_state hold an icon preview for now
/datum/sprite_accessory/skin
	icon = 'icons/mob/human_races/r_human.dmi'

/datum/sprite_accessory/skin/human
	name = "Default human skin"
	icon_state = "default"
	species_allowed = list("Human")

/datum/sprite_accessory/skin/human_tatt01
	name = "Tatt01 human skin"
	icon_state = "tatt1"
	species_allowed = list("Human")

/datum/sprite_accessory/skin/tajaran
	name = "Default tajaran skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_tajaran.dmi'
	species_allowed = list("Tajara")

/datum/sprite_accessory/skin/unathi
	name = "Default Unathi skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_lizard.dmi'
	species_allowed = list("Unathi")

/datum/sprite_accessory/skin/skrell
	name = "Default skrell skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_skrell.dmi'
	species_allowed = list("Skrell")

/datum/sprite_accessory/moth_wings
	species_allowed = list("Moth")
	do_colouration = FALSE
	icon = 'icons/mob/species/moth/wings.dmi'

/datum/sprite_accessory/moth_wings/plain
	name = "Plain"
	icon_state = "plain"

/datum/sprite_accessory/moth_wings/monarch
	name = "Monarch"
	icon_state = "monarch"

/datum/sprite_accessory/moth_wings/luna
	name = "Luna"
	icon_state = "luna"

/datum/sprite_accessory/moth_wings/atlas
	name = "Atlas"
	icon_state = "atlas"

/datum/sprite_accessory/moth_wings/reddish
	name = "Reddish"
	icon_state = "redish"

/datum/sprite_accessory/moth_wings/royal
	name = "Royal"
	icon_state = "royal"

/datum/sprite_accessory/moth_wings/gothic
	name = "Gothic"
	icon_state = "gothic"

/datum/sprite_accessory/moth_wings/lovers
	name = "Lovers"
	icon_state = "lovers"

/datum/sprite_accessory/moth_wings/whitefly
	name = "White Fly"
	icon_state = "whitefly"

/datum/sprite_accessory/moth_wings/punished
	name = "Burnt Off"
	icon_state = "punished"

/datum/sprite_accessory/moth_wings/firewatch
	name = "Firewatch"
	icon_state = "firewatch"

/datum/sprite_accessory/moth_wings/deathhead
	name = "Deathshead"
	icon_state = "deathhead"

/datum/sprite_accessory/moth_wings/poison
	name = "Poison"
	icon_state = "poison"

/datum/sprite_accessory/moth_wings/ragged
	name = "Ragged"
	icon_state = "ragged"

/datum/sprite_accessory/moth_wings/moonfly
	name = "Moon Fly"
	icon_state = "moonfly"

/datum/sprite_accessory/moth_wings/snow
	name = "Snow"
	icon_state = "snow"
