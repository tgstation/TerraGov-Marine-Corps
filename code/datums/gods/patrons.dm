GLOBAL_LIST_EMPTY(patronlist)

#define CLERIC_SPELLS "Cleric"
#define PRIEST_SPELLS "Priest"

/datum/patrongods
	var/name
	var/domain
	var/summary
	var/worshippers
	var/t0
	var/t1
	var/t2
	var/t3

/datum/patrongods/astrata
	name = "Astrata"
	domain = "Goddess of the Sun, Day, and Order"
	summary = "The Firstborn of Psydon, twin of Noc, gifted man the Sun as her divine gift."
	worshippers = "The Noble Hearted, Zealots, Farmers"
	t0 = /obj/effect/proc_holder/spell/invoked/heal/lesser
	t1 = /obj/effect/proc_holder/spell/targeted/sacred_flame_rogue
	t2 = /obj/effect/proc_holder/spell/invoked/heal
	t3 = /obj/effect/proc_holder/spell/invoked/revive

/datum/patrongods/noc
	name = "Noc"
	domain = "God of the Moon, Night, and Knowledge"
	summary = "The Firstborn of Psydon, twin of Astrala, gifted man divine knowledge."
	worshippers = " Magic Practitioners, Scholars"

/datum/patrongods/dendor
	name = "Dendor"
	domain = "God of the Earth and Nature"
	summary = "The Primordial Son, patron of beasts and the wood. Gone mad with time."
	worshippers = "Druids, Beasts, Madmen"
	t0 = /obj/effect/proc_holder/spell/invoked/heal/lesser
	t1 = /obj/effect/proc_holder/spell/targeted/blesscrop
	t2 = /obj/effect/proc_holder/spell/targeted/beasttame
	t3 = null

/datum/patrongods/abyssor
	name = "Abyssor"
	domain = "God of the Ocean, Storms and the Tide"
	summary = "The Beloved Son, gifted primordial men food and water."
	worshippers = "Men of the Sea, Primitive Aquatics"

/datum/patrongods/ravox
	name = "Ravox"
	domain = "God of War, Justice and Strength"
	summary = "The strongest of Psydons children, he watches man from afar."
	worshippers = "Warriors, Sellswords & those who seek Justice"

/datum/patrongods/necra
	name = "Necra"
	domain = "Goddess of Death and the Afterlife"
	summary = "The Veiled Lady, a feared but respected God who leads the dead."
	worshippers = " Necromancers, The Dead, Gravekeepers"
	t0 = /obj/effect/proc_holder/spell/invoked/heal/lesser
	t1 = /obj/effect/proc_holder/spell/targeted/burialrite
	t2 = /obj/effect/proc_holder/spell/targeted/churn
	t3 = /obj/effect/proc_holder/spell/targeted/soulspeak

/datum/patrongods/xylix
	name = "Xylix"
	domain = "God of Trickery, Freedom and Inspiration"
	summary = "The Mad-God, gifted man wanderlust and a thousand tricks."
	worshippers = "Cheats & Frauds, Silver-Tongued devils and Roguish Types"

/datum/patrongods/pestra
	name = "Pestra"
	domain = "Goddess of Decay, Disease and Medicine"
	summary = "The Loving Daughter of Psydon, gifted man medicine."
	worshippers = "The Sick, Phyicians, Apothecaries"

/datum/patrongods/malum
	name = "Malum"
	domain = "God of Fire, Destruction and Rebirth"
	summary = "The Opinionless God, his children hold no malice in their actions."
	worshippers = "Smiths, Miners, Artists."

/datum/patrongods/eora
	name = "Eora"
	domain = "Goddess of the Family, Love and Lust"
	summary = "The Lovely One, her divine gift was that of family and love."
	worshippers = "Lovers, Harlots, Doting Grandparents"



