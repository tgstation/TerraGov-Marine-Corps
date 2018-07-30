var/global/list/gear_datums = list()

/hook/startup/proc/populate_gear_list()
	for(var/type in typesof(/datum/gear)-/datum/gear)
		var/datum/gear/G = new type()
		gear_datums[G.display_name] = G
	return 1

/datum/gear
	var/display_name       //Name/index.
	var/path               //Path to item.
	var/cost               //Number of points used.
	var/slot               //Slot to equip to.
	var/list/allowed_roles //Roles that can spawn with this item.
	var/whitelisted        //Term to check the whitelist for..

// This is sorted both by slot and alphabetically! Don't fuck it up!
// Headslot items

/datum/gear/cmbandana
	display_name = "USCM Bandana (Green)"
	path = /obj/item/clothing/head/cmbandana
	cost = 3
	slot = WEAR_HEAD

/datum/gear/cmbandanatan
	display_name = "USCM Bandana (Tan)"
	path = /obj/item/clothing/head/cmbandana/tan
	cost = 3
	slot = WEAR_HEAD

/datum/gear/cmberet
	display_name = "USCM Beret (Green)"
	path = /obj/item/clothing/head/cmberet
	cost = 3
	slot = WEAR_HEAD

/datum/gear/cmberettan
	display_name = "USCM Beret (Green)"
	path = /obj/item/clothing/head/cmberet
	cost = 3
	slot = WEAR_HEAD

/datum/gear/cmheadband
	display_name = "USCM Headband (Green)"
	path = /obj/item/clothing/head/headband
	cost = 3
	slot = WEAR_HEAD

/datum/gear/cmheadbandred
	display_name = "USCM Headband (Red)"
	path = /obj/item/clothing/head/headband/red
	cost = 3
	slot = WEAR_HEAD

/datum/gear/cmheadset
	display_name = "USCM Earpiece"
	path = /obj/item/clothing/head/headset
	cost = 3
	slot = WEAR_HEAD

/datum/gear/cmcap
	display_name = "USCM Cap"
	path = /obj/item/clothing/head/cmcap
	cost = 3
	slot = WEAR_HEAD
/*
/datum/gear/gbandana
	display_name = "bandana, green"
	path = /obj/item/clothing/head/greenbandana
	cost = 2
	slot = WEAR_HEAD

/datum/gear/bandana
	display_name = "bandana, pirate-red"
	path = /obj/item/clothing/head/bandana
	cost = 2
	slot = WEAR_HEAD

/datum/gear/bsec_beret
	display_name = "beret, blue (security)"
	path = /obj/item/clothing/head/beret/sec/alt
	cost = 1
	slot = WEAR_HEAD
	allowed_roles = list("Military Police")

/datum/gear/eng_beret
	display_name = "beret, engie-orange"
	path = /obj/item/clothing/head/beret/eng
	cost = 2
	slot = WEAR_HEAD
//	allowed_roles = list("Station Engineer","Atmospheric Technician","Chief Engineer")

/datum/gear/purp_beret
	display_name = "beret, purple"
	path = /obj/item/clothing/head/beret/jan
	cost = 2
	slot = WEAR_HEAD

/datum/gear/red_beret
	display_name = "beret, red"
	path = /obj/item/clothing/head/beret
	cost = 2
	slot = WEAR_HEAD

/datum/gear/sec_beret
	display_name = "beret, red (security)"
	path = /obj/item/clothing/head/beret/sec
	cost = 1
	slot = WEAR_HEAD
	allowed_roles = list("Military Police")

/datum/gear/bcap
	display_name = "cap, blue"
	path = /obj/item/clothing/head/soft/blue
	cost = 2
	slot = WEAR_HEAD

/datum/gear/mailman
	display_name = "cap, blue station"
	path = /obj/item/clothing/head/mailman
	cost = 2
	slot = WEAR_HEAD

/datum/gear/flatcap
	display_name = "cap, brown-flat"
	path = /obj/item/clothing/head/flatcap
	cost = 2
	slot = WEAR_HEAD

/datum/gear/corpcap
	display_name = "cap, corporate (Security)"
	path = /obj/item/clothing/head/soft/sec/corp
	cost = 2
	slot = WEAR_HEAD
	allowed_roles = list("Corporate Liaison", "Requisitions officer")

/datum/gear/gcap
	display_name = "cap, green"
	path = /obj/item/clothing/head/soft/green
	cost = 2
	slot = WEAR_HEAD

 /datum/gear/grcap
	display_name = "cap, grey"
	path = /obj/item/clothing/head/soft/grey
	cost = 2
	slot = WEAR_HEAD

 /datum/gear/ocap
	display_name = "cap, orange"
	path = /obj/item/clothing/head/soft/orange
	cost = 2
	slot = WEAR_HEAD

/datum/gear/purcap
	display_name = "cap, purple"
	path = /obj/item/clothing/head/soft/purple
	cost = 2
	slot = WEAR_HEAD

/datum/gear/raincap
	display_name = "cap, rainbow"
	path = /obj/item/clothing/head/soft/rainbow
	cost = 3
	slot = WEAR_HEAD

/datum/gear/rcap
	display_name = "cap, red"
	path = /obj/item/clothing/head/soft/red
	cost = 2
	slot = WEAR_HEAD

/datum/gear/ycap
	display_name = "cap, yellow"
	path = /obj/item/clothing/head/soft/yellow
	cost = 2
	slot = WEAR_HEAD

/datum/gear/hairflower
	display_name = "hair flower pin"
	path = /obj/item/clothing/head/hairflower
	cost = 2
	slot = WEAR_HEAD

/datum/gear/dbhardhat
	display_name = "hardhat, blue"
	path = /obj/item/clothing/head/hardhat/dblue
	cost = 2
	slot = WEAR_HEAD

/datum/gear/ohardhat
	display_name = "hardhat, orange"
	path = /obj/item/clothing/head/hardhat/orange
	cost = 2
	slot = WEAR_HEAD

/datum/gear/yhardhat
	display_name = "hardhat, yellow"
	path = /obj/item/clothing/head/hardhat
	cost = 2
	slot = WEAR_HEAD

/datum/gear/boater
	display_name = "hat, boatsman"
	path = /obj/item/clothing/head/boaterhat
	cost = 2
	slot = WEAR_HEAD

 /datum/gear/bowler
	display_name = "hat, bowler"
	path = /obj/item/clothing/head/bowler
	cost = 2
	slot = WEAR_HEAD

/datum/gear/fez
	display_name = "hat, fez"
	path = /obj/item/clothing/head/fez
	cost = 2
	slot = WEAR_HEAD

/datum/gear/ushanka
	display_name = "ushanka"
	path = /obj/item/clothing/head/ushanka
	cost = 2
	slot = WEAR_HEAD

// This was sprited and coded specifically for Zhan-Khazan characters. Before you
// decide that it's 'not even Taj themed' maybe you should read the wiki, gamer. ~ Z
/datum/gear/zhan_scarf
	display_name = "Zhan headscarf"
	path = /obj/item/clothing/head/tajaran/scarf
	cost = 2
	slot = WEAR_HEAD
	whitelisted = "Tajara"
*/
// Eyes
/*


/datum/gear/green_glasses
	display_name = "Glasses, green"
	path = /obj/item/clothing/glasses/gglasses
	cost = 1

/datum/gear/scanning_goggles
	display_name = "scanning goggles"
	path = /obj/item/clothing/glasses/fluff/uzenwa_sissra_1
	cost = 1
//	allowed_roles = list("Roboticist", "Scientist", "Research Director")

/datum/gear/security
	display_name = "Security HUD"
	path = /obj/item/clothing/glasses/hud/security
	cost = 1
	slot = WEAR_EYES
	allowed_roles = list("Security Officer","Head of Security","Warden")
*/
/datum/gear/eyepatch
	display_name = "Eyepatch"
	path = /obj/item/clothing/glasses/eyepatch
	cost = 2
	slot = WEAR_EYES

/datum/gear/thugshades
	display_name = "Shades"
	path = /obj/item/clothing/glasses/sunglasses/big
	cost = 2
	slot = WEAR_EYES

/datum/gear/prescription
	display_name = "Sunglasses"
	path = /obj/item/clothing/glasses/sunglasses/prescription
	cost = 2
	slot = WEAR_EYES

/datum/gear/cigar
	display_name = "Cigar"
	path = /obj/item/clothing/mask/cigarette/cigar
	slot = WEAR_FACE
	cost = 2

/datum/gear/cigarette
	display_name = "Cigarette"
	path = /obj/item/clothing/mask/cigarette
	slot = WEAR_FACE
	cost = 2
/*
// Mask

/datum/gear/sterilemask
	display_name = "sterile mask"
	path = /obj/item/clothing/mask/surgical
	slot = WEAR_FACE
	cost = 2

// Uniform slot

/datum/gear/exec_suit
	display_name = "executive suit"
	path = /obj/item/clothing/under/suit_jacket/really_black
	slot = WEAR_BODY
	cost = 2

/datum/gear/kilt
	display_name = "kilt"
	path = /obj/item/clothing/under/kilt
	slot = WEAR_BODY
	cost = 3

/datum/gear/skirt_blue
	display_name = "plaid skirt, blue"
	path = /obj/item/clothing/under/dress/plaid_blue
	slot = WEAR_BODY
	cost = 2

/datum/gear/skirt_purple
	display_name = "plaid skirt, purple"
	path = /obj/item/clothing/under/dress/plaid_purple
	slot = WEAR_BODY
	cost = 2

/datum/gear/skirt_red
	display_name = " plaid skirt, red"
	path = /obj/item/clothing/under/dress/plaid_red
	slot = WEAR_BODY
	cost = 2

/datum/gear/skirt_black
	display_name = "skirt, black"
	path = /obj/item/clothing/under/blackskirt
	slot = WEAR_BODY
	cost = 2

/datum/gear/sundress
	display_name = "sundress"
	path = /obj/item/clothing/under/sundress
	slot = WEAR_BODY
	cost = 3

/datum/gear/uniform_captain
	display_name = "uniform, captain's dress"
	path = /obj/item/clothing/under/dress/dress_cap
	slot = WEAR_BODY
	cost = 1
	allowed_roles = list("Captain")

/datum/gear/corpsecsuit
	display_name = "uniform, corporate"
	path = /obj/item/clothing/under/rank/security/corp
	cost = 2
	slot = WEAR_BODY
	allowed_roles = list("Corporate Liaison")

/datum/gear/navysecsuit
	display_name = "uniform, navyblue (Security)"
	path = /obj/item/clothing/under/rank/security/navyblue
	cost = 2
	slot = WEAR_BODY
	allowed_roles = list("Military Police")
*/
// Attachments
/*
/datum/gear/armband_cargo
	display_name = "armband, cargo"
	path = /obj/item/clothing/tie/armband/cargo
	cost = 1

/datum/gear/armband_emt
	display_name = "armband, EMT"
	path = /obj/item/clothing/tie/armband/medgreen
	cost = 2

/datum/gear/armband_engineering
	display_name = "armband, engineering"
	path = /obj/item/clothing/tie/armband/engine
	cost = 1

/datum/gear/armband_hydroponics
	display_name = "armband, hydroponics"
	path = /obj/item/clothing/tie/armband/hydro
	cost = 1

/datum/gear/armband_medical
	display_name = "armband, medical"
	path = /obj/item/clothing/tie/armband/med
	cost = 1

/datum/gear/armband
	display_name = "armband, red"
	path = /obj/item/clothing/tie/armband
	cost = 1

/datum/gear/armband_science
	display_name = "armband, science"
	path = /obj/item/clothing/tie/armband/science
	cost = 1

/datum/gear/armpit
	display_name = "shoulder holster"
	path = /obj/item/clothing/tie/holster/armpit
	cost = 2
	allowed_roles = list("Captain", "Head of Personnel", "Security Officer", "Head of Security")

/datum/gear/tie_blue
	display_name = "tie, blue"
	path = /obj/item/clothing/tie/blue
	cost = 1

/datum/gear/tie_red
	display_name = "tie, red"
	path = /obj/item/clothing/tie/red
	cost = 1

/datum/gear/tie_horrible
	display_name = "tie, socially disgraceful"
	path = /obj/item/clothing/tie/horrible
	cost = 1

/datum/gear/brown_vest
	display_name = "webbing, engineering"
	path = /obj/item/clothing/tie/storage/brown_vest
	cost = 2
	allowed_roles = list("Station Engineer","Atmospheric Technician","Chief Engineer")

/datum/gear/black_vest
	display_name = "webbing, security"
	path = /obj/item/clothing/tie/storage/black_vest
	cost = 2
	allowed_roles = list("Security Officer","Head of Security","Warden")

/datum/gear/webbing
	display_name = "webbing, simple"
	path = /obj/item/clothing/tie/storage/webbing
	cost = 2
*/
// Suit slot
/*
/datum/gear/apron
	display_name = "apron, blue"
	path = /obj/item/clothing/suit/apron
	cost = 1
	slot = WEAR_JACKET

/datum/gear/bomber
	display_name = "bomberjacker"
	path = /obj/item/clothing/suit/bomber
	cost = 4
	slot = WEAR_JACKET

/datum/gear/unathi_mantle
	display_name = "hide mantle (Unathi)"
	path = /obj/item/clothing/suit/unathi/mantle
	cost = 2
	slot = WEAR_JACKET
	whitelisted = "Unathi"

/datum/gear/labcoat
	display_name = "labcoat"
	path = /obj/item/clothing/suit/storage/labcoat
	cost = 3
	slot = WEAR_JACKET

/datum/gear/overalls
	display_name = "overalls"
	path = /obj/item/clothing/suit/apron/overalls
	cost = 2
	slot = WEAR_JACKET

/datum/gear/gponcho
	display_name = "poncho, green"
	path = /obj/item/clothing/suit/poncho/green
	cost = 4
	slot = WEAR_JACKET

/datum/gear/rponcho
	display_name = "poncho, red"
	path = /obj/item/clothing/suit/poncho/red
	cost = 4
	slot = WEAR_JACKET

/datum/gear/poncho
	display_name = "poncho, tan"
	path = /obj/item/clothing/suit/poncho
	cost = 4
	slot = WEAR_JACKET

/datum/gear/unathi_robe
	display_name = "roughspun robe (Unathi)"
	path = /obj/item/clothing/suit/unathi/robe
	cost = 3
	slot = WEAR_JACKET
//	whitelisted = "Unathi" // You don't have a monopoly on a robe!

/datum/gear/suspenders
	display_name = "suspenders"
	path = /obj/item/clothing/suit/suspenders
	cost = 2
	slot = WEAR_JACKET

/datum/gear/wcoat
	display_name = "waistcoat"
	path = /obj/item/clothing/suit/wcoat
	cost = 2
	slot = WEAR_JACKET

/datum/gear/zhan_furs
	display_name = "Zhan-Khazan furs (Tajaran)"
	path = /obj/item/clothing/suit/tajaran/furs
	cost = 3
	slot = WEAR_JACKET
	whitelisted = "Tajara" // You do have a monopoly on a fur suit tho

// Gloves

/datum/gear/black_gloves
	display_name = "gloves, black"
	path = /obj/item/clothing/gloves/black
	cost = 2
	slot = WEAR_HANDS

/datum/gear/blue_gloves
	display_name = "gloves, blue"
	path = /obj/item/clothing/gloves/blue
	cost = 1
	slot = WEAR_HANDS

/datum/gear/brown_gloves
	display_name = "gloves, brown"
	path = /obj/item/clothing/gloves/brown
	cost = 2
	slot = WEAR_HANDS

/datum/gear/green_gloves
	display_name = "gloves, green"
	path = /obj/item/clothing/gloves/green
	cost = 1
	slot = WEAR_HANDS

/datum/gear/orange_gloves
	display_name = "gloves, orange"
	path = /obj/item/clothing/gloves/orange
	cost = 1
	slot = WEAR_HANDS

/datum/gear/red_gloves
	display_name = "gloves, red"
	path = /obj/item/clothing/gloves/red
	cost = 1
	slot = WEAR_HANDS

/datum/gear/white_gloves
	display_name = "gloves, white"
	path = /obj/item/clothing/gloves/white
	cost = 2
	slot = WEAR_HANDS

// Shoelocker

/datum/gear/jackboots
	display_name = "jackboots"
	path = /obj/item/clothing/shoes/jackboots
	cost = 2
	slot = WEAR_FEET

/datum/gear/sandal
	display_name = "sandals"
	path = /obj/item/clothing/shoes/sandal
	cost = 1
	slot = WEAR_FEET

/datum/gear/black_shoes
	display_name = "shoes, black"
	path = /obj/item/clothing/shoes/black
	cost = 1
	slot = WEAR_FEET

/datum/gear/blue_shoes
	display_name = "shoes, blue"
	path = /obj/item/clothing/shoes/blue
	cost = 1
	slot = WEAR_FEET

/datum/gear/brown_shoes
	display_name = "shoes, brown"
	path = /obj/item/clothing/shoes/brown
	cost = 1
	slot = WEAR_FEET

/datum/gear/laceyshoes
	display_name = "shoes, classy"
	path = /obj/item/clothing/shoes/laceup
	cost = 1
	slot = WEAR_FEET

/datum/gear/dress_shoes
	display_name = "shoes, dress"
	path = /obj/item/clothing/shoes/centcom
	cost = 1
	slot = WEAR_FEET

/datum/gear/green_shoes
	display_name = "shoes, green"
	path = /obj/item/clothing/shoes/green
	cost = 1
	slot = WEAR_FEET

/datum/gear/leather
	display_name = "shoes, leather"
	path = /obj/item/clothing/shoes/leather
	cost = 1
	slot = WEAR_FEET

/datum/gear/orange_shoes
	display_name = "shoes, orange"
	path = /obj/item/clothing/shoes/orange
	cost = 1
	slot = WEAR_FEET

/datum/gear/purple_shoes
	display_name = "shoes, purple"
	path = /obj/item/clothing/shoes/purple
	cost = 1
	slot = WEAR_FEET

/datum/gear/red_shoes
	display_name = "shoes, red"
	path = /obj/item/clothing/shoes/red
	cost = 1
	slot = WEAR_FEET

/datum/gear/white_shoes
	display_name = "shoes, white"
	path = /obj/item/clothing/shoes/white
	cost = 1
	slot = WEAR_FEET

/datum/gear/yellow_shoes
	display_name = "shoes, yellow"
	path = /obj/item/clothing/shoes/yellow
	cost = 1
	slot = WEAR_FEET

// "Useful" items

/datum/gear/briefcase
	display_name = "briefcase"
	path = /obj/item/storage/briefcase
	cost = 2

/datum/gear/matchbook
	display_name = "matchbook"
	path = /obj/item/storage/box/matches
	cost = 2

// The rest of the trash.

/datum/gear/ashtray
	display_name = "ashtray, plastic"
	path = /obj/item/ashtray/plastic
	cost = 1

/datum/gear/cane
	display_name = "cane"
	path = /obj/item/cane
	cost = 2

/datum/gear/clipboard
	display_name = "clipboard"
	path = /obj/item/clipboard
	cost = 1

/datum/gear/dice
	display_name = "d20"
	path = /obj/item/toy/dice/d20
	cost = 1

/datum/gear/cards
	display_name = "deck of cards"
	path = /obj/item/toy/deck
	cost = 1

/datum/gear/blipstick
	display_name = "lipstick, black"
	path = /obj/item/lipstick/black
	cost = 1

/datum/gear/jlipstick
	display_name = "lipstick, jade"
	path = /obj/item/lipstick/jade
	cost = 1

/datum/gear/plipstick
	display_name = "lipstick, purple"
	path = /obj/item/lipstick/purple
	cost = 1

/datum/gear/rlipstick
	display_name = "lipstick, red"
	path = /obj/item/lipstick
	cost = 1

/datum/gear/comb
	display_name = "purple comb"
	path = /obj/item/fluff/cado_keppel_1
	cost = 2
*/
/datum/gear/cmgoggles
	display_name = "Ballistic Goggles"
	path = /obj/item/clothing/glasses/mgoggles
	cost = 2
	slot = WEAR_EYES

/datum/gear/cmPgoggles
	display_name = "Prescription Goggles"
	path = /obj/item/clothing/glasses/mgoggles/prescription
	cost = 3
	slot = WEAR_EYES
