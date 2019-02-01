/obj/item/marineResearch
	name = "An unidentified Alien Thingy"
	desc = "Researchy thingy!"
	icon = 'icons/Marine/Research/Research_Items.dmi'
	icon_state = "biomass"
	var/list/id = list()

/obj/item/marineResearch/xenomorph
	name = "An unidentified Alien Thingy"
	desc = "Researchy thingy!"
	icon_state = "biomass"




//Xenofauna, you will not find those thing during normal gameplay, see sampler
/obj/item/marineResearch/xenomorph/weed
    name = "Xenoweed sample"
    desc = "Sample of strange plant"
    id = list(RESEARCH_XENOSTART, RESEARCH_XENO_FLORA, RESEARCH_XENO_WEED)

/obj/item/marineResearch/xenomorph/weed/sack
    name = "Sack sample"
    desc = "Sample of strange organic tissue, what partially acid"
    id = list(RESEARCH_XENOSTART, RESEARCH_XENO_FLORA, RESEARCH_XENO_SACK)

//Xenomorph pieces
/obj/item/marineResearch/xenomorph/chitin
	name = "Xenomorph chitin"
	desc = "A sturdy chunk of xenomorph chitin"
	icon_state = "chitin-chunk"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_BIO_PLATING)

/obj/item/marineResearch/xenomorph/muscle
	name = "Xenomorph muscle tissue"
	desc = "A common xenomorph muscle tissue"
	icon_state = "muscle"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_MUSCLES)

/obj/item/marineResearch/xenomorph/chitin/crusher
	name = "Crusher's chitin"
	desc = "A chunk of extremely sturdy and durable Crusher's chitin"
	icon_state = "chitin-crusher"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_BIO_PLATING, RESEARCH_CRUSHER_PLATING)

/obj/item/marineResearch/xenomorph/acid_gland
	name = "Xenomorph acid gland"
	desc = "Strange internal organ of some alien species"
	icon_state = "sentinel"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_CHEMISTRY)

/obj/item/marineResearch/xenomorph/acid_gland/spitter
	name = "Spitter's gland"
	desc = "A more advanced acid gland, that produces strange toxins"
	icon_state = "spitter"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_CHEMISTRY, RESEARCH_XENO_SPITTER)

/obj/item/marineResearch/xenomorph/secretor
	name = "Secretory gland"
	desc = "Strange gland, that secrete high variety of alien fauna"
	icon_state = "drone"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_MUSCLES, RESEARCH_XENO_FLORA, RESEARCH_XENO_DRONE)

/obj/item/marineResearch/xenomorph/secretor/hivelord
	name = "Hivelord's bioplasma syntesate"
	desc = "Bizzare tissue, that can be abudantly found in Hivelord body"
	icon_state = "hivelord"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_MUSCLES, RESEARCH_XENO_CHEMISTRY, RESEARCH_XENO_FLORA, RESEARCH_XENO_HIVELORD)



//Fun stuff from Queens
/obj/item/marineResearch/xenomorph/core
	name = "Queen's core"
	desc = "Highly complex and advanced organ, that can be found inside Queen's head"
	icon_state = "core"
	id = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_QUEEN)