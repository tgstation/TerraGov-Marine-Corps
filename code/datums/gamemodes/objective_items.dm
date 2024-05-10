//Contains the target item datums for Steal objectives.

/datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/toy/bikehorn		//typepath of the objective item
	var/difficulty = 9001							//vaguely how hard it is to do this objective
	var/list/excludefromjob = list()				//If you don't want a job to get a certain objective (no captain stealing his own medal, etcetc)

/datum/objective_item/proc/TargetExists()
	return TRUE

/datum/objective_item/steal/New()
	..()
	if(TargetExists())
		GLOB.possible_items += src
	else
		qdel(src)

/datum/objective_item/steal/Destroy()
	GLOB.possible_items -= src
	return ..()

/datum/objective_item/steal/blueprints
	name = "the classified blueprints."
	targetitem = /obj/item/blueprints
	difficulty = 10

/datum/objective_item/steal/xenofinance
	name = "the confidential xeno financial papers."
	targetitem = /obj/item/paper/xenofinance
	difficulty = 10

/datum/objective_item/steal/hypercell
	name = "the hyper-capacity power cell."
	targetitem = /obj/item/cell/hyper
	difficulty = 5

/datum/objective_item/steal/rounyred
	name = "the rare rouny doll."
	targetitem = /obj/item/toy/plush/rouny
	difficulty = 20

/datum/objective_item/steal/rounyred
	name = "the rare rouny doll."
	targetitem = /obj/item/toy/plush/rouny
	difficulty = 20

/datum/objective_item/steal/phoronsingle
	name = "the phoron ingot."
	targetitem = /obj/item/stack/sheet/mineral/phoron
	difficulty = 10

/datum/objective_item/steal/phoronmedium
	name = "the medium collection of phoron ingots."
	targetitem = /obj/item/stack/sheet/mineral/phoron/medium_stack
	difficulty = 10

/datum/objective_item/steal/phoronsmall
	name = "the small collection of phoron ingots."
	targetitem = /obj/item/stack/sheet/mineral/phoron/small_stack
	difficulty = 10

/datum/objective_item/steal/clownshoes
	name = "the clown shoes."
	targetitem = /obj/item/clothing/shoes/clown_shoes
	difficulty = 10

/datum/objective_item/steal/xenosuit
	name = "the xenomorph disguise."
	targetitem = /obj/item/clothing/suit/xenos
	difficulty = 10

/datum/objective_item/steal/fireproofjelly
	name = "the fireproof jelly."
	targetitem = /obj/item/resin_jelly
	difficulty = 10

/datum/objective_item/steal/cat
	name = "the captain's cat."
	targetitem = /obj/item/clothing/head/cat
	difficulty = 10

/datum/objective_item/steal/goldenviolin
	name = "the golden violin"
	targetitem = /obj/item/instrument/violin/golden
	difficulty = 10

/datum/objective_item/steal/diamond
	name = "the priceless diamond."
	targetitem = /obj/item/stack/sheet/mineral/diamond
	difficulty = 10

/datum/objective_item/steal/nucleardisk
	name = "the nuclear disk."
	targetitem = /obj/item/disk/nuclear
	difficulty = 10

/datum/objective_item/steal/goldenapple
	name = "the first place trophy."
	targetitem = /obj/item/reagent_containers/food/snacks/grown/goldapple
	difficulty = 10

/datum/objective_item/steal/engineeringhackingguide
	name = "the engineer's guide to hacking."
	targetitem = /obj/item/book/manual/engineering_hacking
	difficulty = 10

/datum/objective_item/steal/emag
	name = "the working cryptographic sequencer."
	targetitem = /obj/item/card/emag
	difficulty = 10

/datum/objective_item/steal/thermalgoggles
	name = "the thermal goggles."
	targetitem = /obj/item/clothing/glasses/thermal
	difficulty = 10

/datum/objective_item/steal/insuls
	name = "the insulated gloves."
	targetitem = /obj/item/clothing/gloves/insulated
	difficulty = 10

/datum/objective_item/steal/teleporterkit
	name = "the teleporter kit."
	targetitem = /obj/item/teleporter_kit
	difficulty = 10

/datum/objective_item/steal/brain
	name = "the human brain."
	targetitem = /obj/item/organ/brain
	difficulty = 10

/datum/objective_item/steal/skub
	name = "the skub."
	targetitem = /obj/item/skub
	difficulty = 10

/datum/objective_item/steal/monkeycubes
	name = "the monkey cube box."
	targetitem = /obj/item/storage/box/monkeycubes
	difficulty = 10

/datum/objective_item/steal/supplytablet
	name = "the supply tablet."
	targetitem = /obj/item/supplytablet
	difficulty = 10

/datum/objective_item/steal/cultistknife
	name = "the Narsian blade."
	targetitem = /obj/item/tool/kitchen/knife/ritual
	difficulty = 10

/datum/objective_item/steal/goldentrophy
	name = "the golden trophy."
	targetitem = /obj/item/reagent_containers/food/drinks/golden_cup
	difficulty = 10

/datum/objective_item/steal/captainmedal
	name = "the captain's medal."
	targetitem = /obj/item/clothing/tie/medal/gold/captain
	difficulty = 10

/datum/objective_item/steal/heroicmedal
	name = "the medal of heroism."
	targetitem = /obj/item/clothing/tie/medal/gold/heroism
	difficulty = 10

/datum/objective_item/steal/goldencoin
	name = "the golden coin."
	targetitem = /obj/item/coin/gold
	difficulty = 10

/datum/objective_item/steal/lockbox
	name = "the lockbox."
	targetitem = /obj/item/storage/lockbox
	difficulty = 10

/datum/objective_item/steal/blueesword
	name = "the blue energy sword."
	targetitem = /obj/item/weapon/energy/sword/blue
	difficulty = 10

/datum/objective_item/steal/redesword
	name = "the red energy sword."
	targetitem = /obj/item/weapon/energy/sword/red
	difficulty = 10

/datum/objective_item/steal/pinpointer
	name = "the pinpointer."
	targetitem = /obj/item/pinpointer
	difficulty = 10
