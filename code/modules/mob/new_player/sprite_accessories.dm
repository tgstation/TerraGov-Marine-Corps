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

	var/list/species_allowed = list("Human","Human Hero", "Synthetic", "Early Synthetics", "Vat-Grown", "Vatborn") // Restrict some styles to specific species
	var/do_colouration = TRUE	// Whether or not the accessory can be affected by colouration


/*
////////////////////////////
/  =--------------------=  /
/  == Hair Definitions ==  /
/  =--------------------=  /
////////////////////////////
*/

/datum/sprite_accessory/hair
	species_allowed = list("Human","Synthetic","Early Synthetic", "Vat-Grown", "Vatborn")
	icon = 'icons/mob/Human_face.dmi'

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = "bald"

/datum/sprite_accessory/hair/eighties
	name = "80's"
	icon_state = "hair_80s"

/datum/sprite_accessory/hair/adamjensen
	name = "Adam Jensen Hair"
	icon_state = "hair_adamjensen"
	gender = MALE

/datum/sprite_accessory/hair/ai
	name = "Artificially Intelligent"
	icon_state = "hair_ai"
	gender = FEMALE

/datum/sprite_accessory/hair/averagejoe
	name = "Average Joe"
	icon_state = "hair_averagejoe"
	gender = MALE

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "hair_afro"

/datum/sprite_accessory/hair/amazon
	name = "Amazon"
	icon_state = "hair_amazon"
	gender = FEMALE

/datum/sprite_accessory/hair/antenna
	name = "Antenna"
	icon_state = "hair_antenna"
	gender = FEMALE

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "hair_balding"
	gender = MALE

/datum/sprite_accessory/hair/baldingfade
	name = "Balding Fade"
	icon_state = "hair_baldingfade"
	gender = MALE

/datum/sprite_accessory/hair/bangsshort
	name = "Bangs Short"
	icon_state = "hair_bangsshort"
	gender = FEMALE

/datum/sprite_accessory/hair/beachwave
	name = "Beach Waves"
	icon_state = "hair_beachwave"
	gender = FEMALE

/datum/sprite_accessory/hair/belenko
	name = "Belenko"
	icon_state = "hair_belenko"

/datum/sprite_accessory/hair/belenkotied
	name = "Belenko Tied"
	icon_state = "hair_belenkotied"

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "hair_beehive"
	gender = FEMALE

/datum/sprite_accessory/hair/beehive2
	name = "Beehive 2"
	icon_state = "hair_beehive2"
	gender = FEMALE

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "hair_bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "hair_bedhead2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "hair_bedhead3"

/datum/sprite_accessory/hair/bob
	name = "Bob Hair"
	icon_state = "hair_bob"

/datum/sprite_accessory/hair/bob2
	name = "Bob Hair 2"
	icon_state = "hair_bob2"

/datum/sprite_accessory/hair/bobcurl
	name = "Bobcurl"
	icon_state = "hair_bobcurl"
	gender = FEMALE

/datum/sprite_accessory/hair/bobcut
	name = "Bobcut"
	icon_state = "hair_bobcut"
	gender = FEMALE

/datum/sprite_accessory/hair/bobcutalt
	name = "Bobcut Alternate"
	icon_state = "hair_bobcutalt"
	gender = FEMALE

/datum/sprite_accessory/hair/boddicker
	name = "Boddicker"
	icon_state = "hair_boddicker"
	gender = MALE

/datum/sprite_accessory/hair/braidgrande
	name = "Braid Grande"
	icon_state = "hair_braidgrande"
	gender = FEMALE

/datum/sprite_accessory/hair/braidlong
	name = "Braid Long"
	icon_state = "hair_braidlong"
	gender = FEMALE

/datum/sprite_accessory/hair/braidmedium
	name = "Braid Medium"
	icon_state = "hair_braidmedium"
	gender = FEMALE

/datum/sprite_accessory/hair/business
	name = "Business Hair"
	icon_state = "hair_business"
	gender = MALE

/datum/sprite_accessory/hair/business2
	name = "Business Hair 2"
	icon_state = "hair_business2"
	gender = MALE

/datum/sprite_accessory/hair/business3
	name = "Business Hair 3"
	icon_state = "hair_business3"
	gender = MALE

/datum/sprite_accessory/hair/bun
	name = "Bun"
	icon_state = "hair_bun"
	gender = FEMALE

/datum/sprite_accessory/hair/bun2
	name = "Bun 2"
	icon_state = "hair_bun2"
	gender = FEMALE

/datum/sprite_accessory/hair/bun3
	name = "Bun 3"
	icon_state = "hair_bun3"
	gender = FEMALE

/datum/sprite_accessory/hair/bun4
	name = "Bun 4"
	icon_state = "hair_bun4"
	gender = FEMALE

/datum/sprite_accessory/hair/bundonut
	name = "Bun Donut"
	icon_state = "hair_bundonut"
	gender = FEMALE

/datum/sprite_accessory/hair/buntight
	name = "Bun Tight"
	icon_state = "hair_buntight"
	gender = FEMALE

/datum/sprite_accessory/hair/bunovereye
	name = "Bun Overeye"
	icon_state = "hair_bun_overeye"
	gender = FEMALE

/datum/sprite_accessory/hair/bunshaved
	name = "Bun Shaved"
	icon_state = "hair_bunshaved"
	gender = FEMALE

/datum/sprite_accessory/hair/buzzcut
	name = "Buzzcut"
	icon_state = "hair_buzzcut"
	gender = MALE

/datum/sprite_accessory/hair/buzzcut2
	name = "Buzzcut 2"
	icon_state = "hair_buzzcut2"
	gender = MALE

/datum/sprite_accessory/hair/celebcurls
	name = "Celeb Curls"
	icon_state = "hair_celebcurls"
	gender = FEMALE

/datum/sprite_accessory/hair/chrono
	name = "Chrono"
	icon_state = "hair_chrono"
	gender = MALE

/datum/sprite_accessory/hair/cia
	name = "CIA"
	icon_state = "hair_cia"
	gender = MALE

/datum/sprite_accessory/hair/coffeehousecut
	name = "Coffee House Cut"
	icon_state = "hair_coffeehousecut"
	gender = MALE

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "hair_combover"
	gender = MALE

/datum/sprite_accessory/hair/combover2
	name = "Combover 2"
	icon_state = "hair_combover2"
	gender = MALE

/datum/sprite_accessory/hair/cornrows
	name = "Corn Rows"
	icon_state = "hair_cornrows"
	gender = FEMALE

/datum/sprite_accessory/hair/country
	name = "Country"
	icon_state = "hair_country"
	gender = FEMALE

/datum/sprite_accessory/hair/cpldietrich
	name = "Cpl. Dietrich"
	icon_state = "hair_cpldietrich"
	gender = FEMALE

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "hair_crewcut"
	gender = MALE

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "hair_curls"

/datum/sprite_accessory/hair/curly
	name = "Curly Hair"
	icon_state = "hair_curly"
	gender = FEMALE

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "hair_cut"

/datum/sprite_accessory/hair/dave
	name = "Dave"
	icon_state = "hair_dave"
	gender = MALE

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "hair_devilock"

/datum/sprite_accessory/hair/drillruru
	name = "Drillruru"
	icon_state = "hair_drillruru"
	gender = FEMALE

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "hair_emo"

/datum/sprite_accessory/hair/emo2
	name = "Emo 2"
	icon_state = "hair_emo2"

/datum/sprite_accessory/hair/fringeemo
	name = "Emo Fringe"
	icon_state = "hair_emofringe"
	gender = FEMALE

/datum/sprite_accessory/hair/emolong
	name = "Emo Long"
	icon_state = "hair_emolong"
	gender = FEMALE

/datum/sprite_accessory/hair/emolongside
	name = "Emo Long Side"
	icon_state = "hair_emolongside"
	gender = FEMALE

/datum/sprite_accessory/hair/fade
	name = "Fade"
	icon_state = "hair_fade"
	gender = MALE

/datum/sprite_accessory/hair/fademed
	name = "Fademed"
	icon_state = "hair_fademed"
	gender = MALE

/datum/sprite_accessory/hair/fadehigh
	name = "Fadehigh"
	icon_state = "hair_fadehigh"
	gender = MALE

/datum/sprite_accessory/hair/fadeparted
	name = "Fade Parted"
	icon_state = "hair_fadeparted"
	gender = MALE

/datum/sprite_accessory/hair/father
	name = "Father"
	icon_state = "hair_father"
	gender = MALE

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "hair_feather"

/datum/sprite_accessory/hair/flaired
	name = "Flaired Hair"
	icon_state = "hair_flaired"

/datum/sprite_accessory/hair/flaired2
	name = "Flaired Hair 2"
	icon_state = "hair_flaired2"
	gender = FEMALE

/datum/sprite_accessory/hair/flattop
	name = "Flat Top"
	icon_state = "hair_flattop"

/datum/sprite_accessory/hair/flattopfade
	name = "Flat Top Fade"
	icon_state = "hair_flattopfade"
	gender = MALE

/datum/sprite_accessory/hair/flow
	name = "Flow Hair"
	icon_state = "hair_flow"

/datum/sprite_accessory/hair/fringetail
	name = "Fringetail"
	icon_state = "hair_fringetail"
	gender = FEMALE

/datum/sprite_accessory/hair/gelledback
	name = "Gelled Back"
	icon_state = "hair_gelledback"
	gender = FEMALE

/datum/sprite_accessory/hair/gentle
	name = "Gentle"
	icon_state = "hair_gentle"
	gender = FEMALE

/datum/sprite_accessory/hair/gentle2
	name = "Gentle 2"
	icon_state = "hair_gentle2"
	gender = FEMALE

/datum/sprite_accessory/hair/gentle2long
	name = "Gentle 2 Long"
	icon_state = "hair_gentle2long"
	gender = FEMALE

/datum/sprite_accessory/hair/gentleman
	name = "Gentleman's Cut"
	icon_state = "hair_cleancut"
	gender = MALE

/datum/sprite_accessory/hair/halfbanged
	name = "Half-banged Hair"
	icon_state = "hair_halfbanged"

/datum/sprite_accessory/hair/halfbangedalt
	name = "Half-banged Hair Alternate"
	icon_state = "hair_halfbangedalt"

/datum/sprite_accessory/hair/halfshaved
	name = "Half-Shaved"
	icon_state = "hair_halfshaved"
	gender = FEMALE

/datum/sprite_accessory/hair/halfshavedemo
	name = "Half-Shaved Emo"
	icon_state = "hair_halfshavedemo"
	gender = FEMALE

/datum/sprite_accessory/hair/headstubble
	name = "Head Stubble"
	icon_state = "hair_headstubble"

/datum/sprite_accessory/hair/highandtight
	name = "High and Tight"
	icon_state = "hair_highandtight"
	gender = MALE

/datum/sprite_accessory/hair/highfade
	name = "High Fade"
	icon_state = "hair_highfade"

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "hair_himecut"
	gender = FEMALE

/datum/sprite_accessory/hair/himecutalt
	name = "Hime Cut Alternate"
	icon_state = "hair_himecut_alt"
	gender = FEMALE

/datum/sprite_accessory/hair/himecutalt2
	name = "Hime Cut Alternate 2"
	icon_state = "hair_himecut_alt2"
	gender = FEMALE

/datum/sprite_accessory/hair/himecutlong
	name = "Hime Cut Long"
	icon_state = "hair_himecut_long"
	gender = FEMALE

/datum/sprite_accessory/hair/himecutlongponytail
	name = "Hime Cut Long Ponytail"
	icon_state = "hair_himecut_long_ponytail"
	gender = FEMALE

/datum/sprite_accessory/hair/himecutponytail
	name = "Hime Cut Ponytail"
	icon_state = "hair_himecut_ponytail"
	gender = FEMALE

/datum/sprite_accessory/hair/himecutponytailup
	name = "Hime Cut Ponytail Up"
	icon_state = "hair_himecut_ponytail_up"
	gender = FEMALE

/datum/sprite_accessory/hair/himecutshort
	name = "Hime Cut Short"
	icon_state = "hair_himecutshort"
	gender = FEMALE

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hair_hitop"
	gender = MALE

/datum/sprite_accessory/hair/iceman
	name = "Iceman"
	icon_state = "hair_iceman"
	gender = MALE

/datum/sprite_accessory/hair/jade
	name = "Jade"
	icon_state = "hair_jade"
	gender = FEMALE

/datum/sprite_accessory/hair/jensen
	name = "Jensen"
	icon_state = "hair_jensen"
	gender = MALE

/datum/sprite_accessory/hair/jessica
	name = "Jessica"
	icon_state = "hair_jessica"
	gender = FEMALE

/datum/sprite_accessory/hair/joestar
	name = "Joestar"
	icon_state = "hair_joestar"
	gender = MALE

/datum/sprite_accessory/hair/keanu
	name = "Keanu Hair"
	icon_state = "hair_keanu"

/datum/sprite_accessory/hair/kusangi
	name = "Kusanagi Hair"
	icon_state = "hair_kusanagi"

/datum/sprite_accessory/hair/long
	name = "Long Hair"
	icon_state = "hair_long"

/datum/sprite_accessory/hair/longalt
	name = "Long Hair Alternate"
	icon_state = "hair_longalt"

/datum/sprite_accessory/hair/longalt2
	name = "Long Hair Alternate 2"
	icon_state = "hair_longalt2"

/datum/sprite_accessory/hair/longstraight
	name = "Long Straight Hair"
	icon_state = "hair_longstraight"

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "hair_longfringe"

/datum/sprite_accessory/hair/longerfringe
	name = "Longer Fringe"
	icon_state = "hair_longerfringe"

/datum/sprite_accessory/hair/lowfade
	name = "Low Fade"
	icon_state = "hair_lowfade"

/datum/sprite_accessory/hair/ltrasczak
	name = "Lt. Rasczak"
	icon_state = "hair_ltrasczak"
	gender = MALE

/datum/sprite_accessory/hair/manbun
	name = "Manbun"
	icon_state = "hair_manbun"
	gender = MALE

/datum/sprite_accessory/hair/marine_flat_top
	name = "Marine Flat Top"
	icon_state = "hair_mflattop"
	gender = FEMALE

/datum/sprite_accessory/hair/marine_mohawk
	name = "Marine Mohawk"
	icon_state = "hair_mmarinemohawk"
	gender = MALE

/datum/sprite_accessory/hair/marysue
	name = "Mary Sue"
	icon_state = "hair_marysue"
	gender = FEMALE

/datum/sprite_accessory/hair/messy
	name = "Messy 1"
	icon_state = "hair_messy"

/datum/sprite_accessory/hair/messy2
	name = "Messy 2"
	icon_state = "hair_messy2"

/datum/sprite_accessory/hair/messy3
	name = "Messy 3"
	icon_state = "hair_messy3"

/datum/sprite_accessory/hair/modern
	name = "Modern"
	icon_state = "hair_modern"
	gender = FEMALE

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "hair_mohawk"

/datum/sprite_accessory/hair/mohawkmarine
	name = "Mohawk Marine"
	icon_state = "hair_mohawkmarine"
	gender = MALE

/datum/sprite_accessory/hair/mohawknaomi
	name = "Mohawk Naomi"
	icon_state = "hair_mohawknaomi"
	gender = FEMALE

/datum/sprite_accessory/hair/mohawkshaved
	name = "Mohawk Shaved"
	icon_state = "hair_mohawkshaved"
	gender = MALE

/datum/sprite_accessory/hair/mohawkshavedtight
	name = "Mohawk Shaved Tight"
	icon_state = "hair_mohawkshavedtight"

/datum/sprite_accessory/hair/mulder
	name = "Mulder"
	icon_state = "hair_mulder"
	gender = MALE

/datum/sprite_accessory/hair/mullet
	name = "Mullet"
	icon_state = "hair_mullet"
	gender = MALE

/datum/sprite_accessory/hair/newyou
	name = "New You"
	icon_state = "hair_newyou"
	gender = FEMALE

/datum/sprite_accessory/hair/nia
	name = "Nia"
	icon_state = "hair_nia"
	gender = FEMALE

/datum/sprite_accessory/hair/nitori
	name = "Nitori"
	icon_state = "hair_nitori"
	gender = FEMALE

/datum/sprite_accessory/hair/nofade
	name = "No Fade"
	icon_state = "hair_nofade"

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "hair_ombre"
	gender = FEMALE

/datum/sprite_accessory/hair/overeyelong
	name = "Overeye Long"
	icon_state = "hair_overeyelong"

/datum/sprite_accessory/hair/overeyeshort
	name = "Overeye Short"
	icon_state = "hair_overeyeshort"

/datum/sprite_accessory/hair/overeyeveryshort
	name = "Overeye Very Short"
	icon_state = "hair_overeyeveryshort"

/datum/sprite_accessory/hair/overeyeveryshortalt
	name = "Overeye Very Short Alternate"
	icon_state = "hair_overeyeveryshortalt"

/datum/sprite_accessory/hair/oxton
	name = "Oxton"
	icon_state = "hair_oxton"

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "hair_parted"

/datum/sprite_accessory/hair/partedalt
	name = "Parted Alternate"
	icon_state = "hair_parted_alt"

/datum/sprite_accessory/hair/partedswept
	name = "Parted Swept"
	icon_state = "hair_parted_swept"

/datum/sprite_accessory/hair/pigtails
	name = "Pigtails"
	icon_state = "hair_pigtails"
	gender = FEMALE

/datum/sprite_accessory/hair/pixie
	name = "Pixie Cut"
	icon_state = "hair_pixie"
	gender = FEMALE

/datum/sprite_accessory/hair/pixiecutleft
	name = "Pixie Cut Left"
	icon_state = "hair_pixiecutleft"
	gender = FEMALE

/datum/sprite_accessory/hair/pixiecutright
	name = "Pixie Cut Right"
	icon_state = "hair_pixiecutright"
	gender = FEMALE

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "hair_pompadour"
	gender = MALE

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail 1"
	icon_state = "hair_ponytail1"

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail 2"
	icon_state = "hair_ponytail2"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "hair_ponytail3"

/datum/sprite_accessory/hair/ponytail4
	name = "Ponytail 4"
	icon_state = "hair_ponytail4"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail5
	name = "Ponytail 5"
	icon_state = "hair_ponytail5"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail6
	name = "Ponytail 6"
	icon_state = "hair_ponytail6"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail7
	name = "Ponytail 7"
	icon_state = "hair_ponytail7"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail8
	name = "Ponytail 8"
	icon_state = "hair_ponytail8"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail9
	name = "Ponytail 9"
	icon_state = "hair_ponytail9"
	gender = FEMALE

/datum/sprite_accessory/hair/hair_ponytailhigh
	name = "Ponytail High"
	icon_state = "hair_ponytailhigh"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytailsharp
	name = "Ponytail Sharp"
	icon_state = "hair_ponytailsharp"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytailspiky
	name = "Ponytail Spiky"
	icon_state = "hair_ponytailspiky"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytaillong
	name = "Ponytail Long"
	icon_state = "hair_ponytaillong"
	gender = FEMALE

/datum/sprite_accessory/hair/poofy
	name = "Poofy"
	icon_state = "hair_poofy"
	gender = FEMALE

/datum/sprite_accessory/hair/poofy2
	name = "Poofy 2"
	icon_state = "hair_poofy2"
	gender = FEMALE

/datum/sprite_accessory/hair/proper
	name = "Proper"
	icon_state = "hair_proper"

/datum/sprite_accessory/hair/protagonist
	name = "Protagonist"
	icon_state = "hair_protagonist"

/datum/sprite_accessory/hair/pvt_clarison
	name = "Pvt. Clarison"
	icon_state = "hair_pvtclari"
	gender = FEMALE

/datum/sprite_accessory/hair/pvtjoker
	name = "Pvt. Joker"
	icon_state = "hair_pvtjoker"
	gender = MALE

/datum/sprite_accessory/hair/pvtredding
	name = "Pvt. Redding"
	icon_state = "hair_pvtredding"
	gender = FEMALE

/datum/sprite_accessory/hair/pvtvasquez
	name = "Pvt. Vasquez"
	icon_state = "hair_pvtvasquez"
	gender = FEMALE

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "hair_quiff"
	gender = MALE

/datum/sprite_accessory/hair/regulationcut
	name = "Regulation Cut"
	icon_state = "hair_regulationcut"
	gender = MALE

/datum/sprite_accessory/hair/reversemohawk
	name = "Reverse Mohawk"
	icon_state = "hair_reversemohawk"
	gender = MALE

/datum/sprite_accessory/hair/ronin
	name = "Ronin"
	icon_state = "hair_ronin"
	gender = MALE

/datum/sprite_accessory/hair/rosa
	name = "Rosa"
	icon_state = "hair_rosa"
	gender = FEMALE

/datum/sprite_accessory/hair/rowbun
	name = "Row Bun"
	icon_state = "hair_rowbun"
	gender = FEMALE

/datum/sprite_accessory/hair/rowbraid
	name = "Row Braid"
	icon_state = "hair_rowbraid"
	gender = FEMALE

/datum/sprite_accessory/hair/rowdualbraid
	name = "Row Dual Braid"
	icon_state = "hair_rowdualbraid"
	gender = FEMALE

/datum/sprite_accessory/hair/rows
	name = "Rows"
	icon_state = "hair_rows"

/datum/sprite_accessory/hair/rows2
	name = "Rows 2"
	icon_state = "hair_rows2"

/datum/sprite_accessory/hair/sabitsuki
	name = "Sabitsuki"
	icon_state = "hair_sabitsuki"

/datum/sprite_accessory/hair/scully
	name = "Scully"
	icon_state = "hair_scully"
	gender = FEMALE

/datum/sprite_accessory/hair/shaved
	name = "Shaved"
	icon_state = "hair_shaved"

/datum/sprite_accessory/hair/short
	name = "Short Hair"
	icon_state = "hair_short"

/datum/sprite_accessory/hair/short2
	name = "Short Hair 2"
	icon_state = "hair_short2"

/datum/sprite_accessory/hair/short3
	name = "Short Hair 3"
	icon_state = "hair_short3"

/datum/sprite_accessory/hair/short4
	name = "Short Hair 4"
	icon_state = "hair_short4"

/datum/sprite_accessory/hair/shoulderlength
	name = "Shoulder-length Hair"
	icon_state = "hair_shoulderlength"

/datum/sprite_accessory/hair/shoulderlengthalt
	name = "Shoulder-length Hair Alternate"
	icon_state = "hair_shoulderlengthalt"

/datum/sprite_accessory/hair/shouldertress
	name = "Shoulder Tress"
	icon_state = "hair_shouldertress"

/datum/sprite_accessory/hair/sidecutleft
	name = "Sidecut Left"
	icon_state = "hair_sidecutleft"

/datum/sprite_accessory/hair/sidecutright
	name = "Sidecut Right"
	icon_state = "hair_sidecutright"

/datum/sprite_accessory/hair/sideponytail
	name = "Side Ponytail"
	icon_state = "hair_sideponytail"
	gender = FEMALE

/datum/sprite_accessory/hair/sideponytail
	name = "Side Ponytail 2"
	icon_state = "hair_sideponytail2"
	gender = FEMALE

/datum/sprite_accessory/hair/sideponytail3
	name = "Shoulder One"
	icon_state = "hair_shoulderone"
	gender = FEMALE

/datum/sprite_accessory/hair/sideswept
	name = "Sideswept Hair"
	icon_state = "hair_sideswept"
	gender = MALE

/datum/sprite_accessory/hair/sideundercut
	name = "Side Undercut"
	icon_state = "hair_sideundercut"

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "hair_skinhead"

/datum/sprite_accessory/hair/sleeze
	name = "Sleeze"
	icon_state = "hair_sleeze"

/datum/sprite_accessory/hair/slick
	name = "Slick"
	icon_state = "hair_slick"

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "hair_spiky"

/datum/sprite_accessory/hair/thinning
	name = "Thinning"
	icon_state = "hair_thinning"
	gender = MALE

/datum/sprite_accessory/hair/thinningback
	name = "Thinning Back"
	icon_state = "hair_thinningback"
	gender = MALE

/datum/sprite_accessory/hair/thinningfront
	name = "Thinning Front"
	icon_state = "hair_thinningfront"
	gender = MALE

/datum/sprite_accessory/hair/topknot
	name = "Topknot"
	icon_state = "hair_topknot"
	gender = MALE

/datum/sprite_accessory/hair/trimmed
	name = "Trimmed"
	icon_state = "hair_trimmed"
	gender = MALE

/datum/sprite_accessory/hair/twintail
	name = "Twintail"
	icon_state = "hair_twintail"
	gender = FEMALE

/datum/sprite_accessory/hair/undercut
	name = "Undercut"
	icon_state = "hair_undercut"
	gender = MALE

/datum/sprite_accessory/hair/unkept
	name = "Unkept"
	icon_state = "hair_unkept"
	gender = FEMALE

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "hair_updo"
	gender = FEMALE

/datum/sprite_accessory/hair/vanilla
	name = "Vanilla"
	icon_state = "hair_vanilla"
	gender = FEMALE

/datum/sprite_accessory/hair/vegeta
	name = "Vegeta"
	icon_state = "hair_vegeta"

/datum/sprite_accessory/hair/verylong
	name = "Very Long Hair"
	icon_state = "hair_verylong"

/datum/sprite_accessory/hair/vivi
	name = "Vivi"
	icon_state = "hair_vivi"

/datum/sprite_accessory/hair/volaju
	name = "Volaju"
	icon_state = "hair_volaju"
	gender = FEMALE

/datum/sprite_accessory/hair/wardaddy
	name = "Wardaddy"
	icon_state = "hair_wardaddy"
	gender = MALE

/datum/sprite_accessory/hair/wisp
	name = "Wisp"
	icon_state = "hair_wisp"
	gender = FEMALE

/datum/sprite_accessory/hair/wheeler
	name = "Wheeler"
	icon_state = "hair_wheeler"
	gender = FEMALE

/datum/sprite_accessory/hair/zieglertail
	name = "Zieglertail"
	icon_state = "hair_ziegler"
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
/////////////////////////////////////
/  =---------------------------=    /
/  == Gradient Hair Definitions ==  /
/  =---------------------------=    /
/////////////////////////////////////
*/

/datum/sprite_accessory/hair_gradient
	icon = 'icons/mob/hair_gradients.dmi'
	gender = NEUTER
	species_allowed = list("Human","Synthetic", "Early Synthetic", "Vat-Grown", "Vatborn")

/datum/sprite_accessory/hair_gradient/none
	name = "None"
	icon_state = "none"

/datum/sprite_accessory/hair_gradient/fadeup
	name = "Fade Up"
	icon_state = "fadeup"

/datum/sprite_accessory/hair_gradient/fadedown
	name = "Fade Down"
	icon_state = "fadedown"

/datum/sprite_accessory/hair_gradient/vertical_split
	name = "Vertical Split"
	icon_state = "vsplit"

/datum/sprite_accessory/hair_gradient/_split
	name = "Horizontal Split"
	icon_state = "bottomflat"

/datum/sprite_accessory/hair_gradient/reflected
	name = "Reflected"
	icon_state = "reflected_high"

/datum/sprite_accessory/hair_gradient/reflected_inverse
	name = "Reflected Inverse"
	icon_state = "reflected_inverse_high"

/datum/sprite_accessory/hair_gradient/wavy
	name = "Wavy"
	icon_state = "wavy"


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
	species_allowed = list("Human","Synthetic", "Early Synthetic", "Vat-Grown", "Vatborn")

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

/datum/sprite_accessory/facial_hair/broken_man
	name = "Broken Man"
	icon_state = "facial_brokenman"

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
