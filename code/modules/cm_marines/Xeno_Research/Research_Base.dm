#define RESEARCH_XENOSTART 0

#define RESEARCH_XENO_BIOLOGY 10
#define RESEARCH_BIO_PLATING 11
#define RESEARCH_CRUSHER_PLATING 12
#define RESEARCH_XENO_MUSCLES 13
#define RESEARCH_XENO_HIVELORD 14
#define RESEARCH_XENO_ARMOR 15

#define RESEARCH_XENO_CHEMISTRY 20
#define RESEARCH_XENO_SPITTER 21

#define RESEARCH_XENO_FLORA 30
#define RESEARCH_XENO_WEED 31
#define RESEARCH_XENO_SACK 32
#define RESEARCH_XENO_DRONE 33

#define RESEARCH_XENO_QUEEN 40
#define RESEARCH_XENO_DISRUPTION 41
#define RESEARCH_XENO_CORRUPTION 42

/datum/marineResearch                        //Holder
	var/list/available_tech = list()		//available to research
	var/list/known_tech = list()			//researched
	var/list/possible_tech = list()			//unavailable to research and not researched
	var/list/known_design = list()			//Designs, that can be built now
	var/list/possible_design = list()		//unavailable for building

/datum/marineResearch/New()
	for(var/T in subtypesof(/datum/marineTech))
		possible_tech += new T(src)
	for(var/T in subtypesof(/datum/marine_design))
		possible_design += new T(src)

/datum/marineResearch/proc/Check_tech(tech)					// return 0 if tech not available nor known, return 1 if known, return 2 if available
	for(var/datum/marineTech/avail in available_tech)
		if(avail.id == tech)
			return 2
	for(var/datum/marineTech/avail in known_tech)
		if(avail.id == tech)
			return 1
	return 0

/datum/marineResearch/proc/TechMakeReq(datum/marineTech/tech)
	var/fl = 1														//Entire existance of this var pisses me the fuck off
	if(istype(tech, /datum/marineTech/Xenomorph))
		return fl
	for(var/req in tech.req_tech)
		fl = 0
		for(var/datum/marineTech/known in known_tech)
			if(known.id == req)
				fl = 1
	return fl

/datum/marineResearch/proc/TechMakeReqInDiss(tech) // Just for checking when about to dissected
	var fl = 1
	for(var/datum/marineTech/possible in possible_tech)
		if(tech != possible.id)
			continue
		if(!possible.need_item)
			continue
		for(var/T in possible.req_tech)
			fl = 0
			for(var/datum/marineTech/known in known_tech)
				if(T == known.id)
					fl = 1
			return fl

/datum/marineResearch/proc/AddToAvail(obj/item/marineResearch/xenomorph/A)
	for(var/datum/marineTech/teches in possible_tech)
		if(Check_tech(teches.id))
			continue
		for(var/tech in A.id)
			if(tech != teches.id)
				continue
			if(TechMakeReq(teches))
				available_tech += teches
				possible_tech -= teches
	return

/datum/marineResearch/proc/CheckAvail()
	var/fl = 1
	for(var/datum/marineTech/possible in possible_tech)
		if(possible.need_item)
			continue
		for(var/id in possible.req_tech)
			fl = 0
			for(var/datum/marineTech/known in known_tech)
				if(known.id == id)
					fl = 1
		if(fl == 1)
			available_tech += possible
			possible_tech -= possible
	return

/datum/marineResearch/proc/CheckDesigns()
	var/fl = 0
	for(var/datum/marine_design/design in possible_design)
		for(var/id in design.req_tech)
			fl = 0
			for(var/datum/marineTech/known in known_tech)
				if(id == known.id)
					fl = 1
		if(!fl)
			continue
		AddDesigns(design)

/datum/marineResearch/proc/AddDesigns(datum/marine_design/design)			//Haphazardous[2]
	possible_design -= design
	known_design += design

/datum/marineResearch/proc/ForcedToKnown(datum/marineTech/tech)				//When we need it to be researched NOW
	switch(Check_tech(tech.id))
		if(0)								//Unknown tech
			possible_tech -= tech
			known_tech += tech
			CheckDesigns()
		if(1)								//Known tech
			return
		if(2)								//To-be-researched tech
			available_tech -= tech
			known_tech += tech
			CheckDesigns()

/datum/marineResearch/proc/AvailToKnown(datum/marineTech/reserched)			//Haphazardous
	available_tech -= reserched
	known_tech += reserched
	CheckDesigns()

/datum/marineTech
	var/name = "name"					//Name of the technology.
	var/desc = "description"			//Description before research
	var/resdesc = "resdesc"				//Description after research
	var/id = -1							//An easily referenced ID. Must be numeric.
	var/time = 30						//What time takes to research. In seconds
	var/list/req_tech = list()			//List of required teches
	var/need_item = 1					//For cheking if item needed for research

/*
///// List of ids for teches/////

//First letter determinates path, second - tech
Starting (Xenomorphs) - RESEARCH_XENOSTART

Xeno Biology - RESEARCH_XENO_BIOLOGY
Bio Plating - RESEARCH_BIO_PLATING
Crusher Plating - RESEARCH_CRUSHER_PLATING
Xeno Muscles - RESEARCH_XENO_MUSCLES
Hivelord thingy - RESEARCH_XENO_HIVELORD

Xeno Chemistry - RESEARCH_XENO_CHEMISTRY
Spitter thingy - RESEARCH_XENO_SPITTER

Xeno Flora - RESEARCH_XENO_FLORA
Xenoweed - RESEARCH_XENO_WEED
Xenosack - RESEARCH_XENO_SACK
Drone thingy - RESEARCH_XENO_DRONE

Queen thingy - RESEARCH_XENO_QUEEN
*/

/datum/marineTech/Xenomorph  //Starting tech
	name = "Xenomorphs"
	desc = "Analysis of alien species."
	resdesc = "Well, lets sink it - we are fighting against increadibly powerful and staggering foe. CLF, UPP, pirates - they are nothing compare to those beasts, if not a monsters. We need research further.."
	id = RESEARCH_XENOSTART


//Xenobiology path//
/datum/marineTech/XenoMBiology
	name = "Xenomorph Biology"
	desc = "Analysis of bizzare nature of Xenomorphs"
	resdesc = "If we thought that humanity is a crowned kings of nature... Xenomorphs are Emperors. Resistant even for vacuum, they blood appears to be acid, that even corrode tank armor... And don't even think about those claws.."
	id = RESEARCH_XENO_BIOLOGY
	req_tech = list(RESEARCH_XENOSTART)
	need_item = 0									//No need for the item

/datum/marineTech/BioPlating
	name = "Xenomorph Armor Plating"
	desc = "Technology of manufacturing valuable plating for standart armor"
	resdesc = "Even their terrifying nature can benefit Colonial Marines with some valuable upgrades. Molecular structure of their chitin are increadibly strong and durable for being biological at fundamental. So much benefits, and no drawbacks..."
	id = RESEARCH_BIO_PLATING
	req_tech = list(RESEARCH_XENO_BIOLOGY)

/datum/marineTech/CrusherPlating
	name = "Crusher chitin patterns"
	desc = "Analysis of durable Crusher's chitin provides us with more reinforced plating"
	resdesc = "Well, to begin with - Crusher is very tenacious fella to kill even with AP rounds. But the best part of it - flamethowers will lighten him up like 4th July and provide us with stronger upgrades!"
	id = RESEARCH_CRUSHER_PLATING
	req_tech = list(RESEARCH_XENO_BIOLOGY)

/datum/marineTech/Muscle
	name = "Xenomorph muscle tissue"
	desc = "Alien muscle tissue using same methods as human muscles, but they proven to be more durable and acid-resistant"
	resdesc = "It's true, that xenomorph claws can pierce armor, thanks to their sharpness. But to make it worse for our troops, Xenomophs have powerful muscle system, that can even withstand the most powerful of acids. It can still be pierced by standart rifle bullets, but have fun to pierce it with 9mm."
	id = RESEARCH_XENO_MUSCLES
	req_tech = list(RESEARCH_XENO_BIOLOGY)

/datum/marineTech/BioArmor
	name = "Chitin Armor."
	desc = "Possible solutions in chitin armor assemble."
	resdesc = "Natural armor of Xenomorph race is something miraculous. It can withstand tremendous damage and regenerate itself. We have enough equipment to bolt in some imitation of this armor."
	id = RESEARCH_XENO_ARMOR
	req_tech = list(RESEARCH_CRUSHER_PLATING, RESEARCH_XENO_MUSCLES)

/datum/marineTech/hivelord
	name = "Hivelord metabolism"
	desc = "Detailed analysis of Hivelords' metabolism shows, that their organism very energy-efficent"
	resdesc = "Wow. Hivelord cannot be poisoned. It cannot overeat either. Whatever it eats, food will provide 100% nutriment, even if it's drugged. Moreover, Hivelord will be basically uncatchable on weed, thanks to sharpened senses and enigmatic connection between xenobiology and xenoflora."
	id = RESEARCH_XENO_HIVELORD
	req_tech = list(RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_MUSCLES, RESEARCH_XENO_CHEMISTRY, RESEARCH_XENO_FLORA, RESEARCH_XENO_DRONE)


//Chemistry path
/datum/marineTech/XenoChem
	name = "Xenomorph Chemistry"
	desc = "Analysis of highly potent Xeno chemistry"
	resdesc = "Foundation of inner xenochemistry is acids. Yes, their blood are acid, their enzymes are acid, their some kind of DNA(Xenomorph-Based Acid onward on) are STRONG acid. Just don't get caught by Sentinels's shots, or it will be painful."
	id = RESEARCH_XENO_CHEMISTRY
	req_tech = list(RESEARCH_XENOSTART)


/datum/marineTech/SpitterChem
	name = "Spitter's toxicity"
	desc = "Potency of Spitter's chemisty was been proven highly effective against any target"
	resdesc = "Spitters are spitting their own XBA at you. They produce it in their glands, but it does not makes it better. But the most facinating about those glands is that they produce XBA of every Xenomorph subspecies."
	id = RESEARCH_XENO_SPITTER
	req_tech = list(RESEARCH_XENO_CHEMISTRY)


//Xenoflora path//
/datum/marineTech/XenoFlora
	name = "Xenomorph Flora"
	desc = "Analysis of xenoflora, abudantly found near all Hives"
	resdesc = "It's not a flora. It's all resins. But our troops ignorant or stupid enough. But somehow, that resin acts like flora anyway and makes some enigmatic connection with xenobiology."
	id = RESEARCH_XENO_FLORA
	req_tech = list(RESEARCH_XENOSTART)
	need_item = 0

/datum/marineTech/XenoWeed
	name = "Xenoweed"
	desc = "Weed - is a main part of xenomorphs's flora, that can somehow interact with xenomorphs's chitin"
	resdesc = "Again, it's not a weed. It's a resin that covers any surface on its way. But it in some way alive, thanks to acting like flora."
	id = RESEARCH_XENO_WEED
	req_tech = list(RESEARCH_XENO_FLORA)

/datum/marineTech/XenoSack
	name = "Purple Sacks"
	desc = "Those sacks - small 'bushes', that produces weed nearby"
	resdesc = "As more we study xenoflora, the more enigmatic it for us. Purple Sack - is a small tank with mixture of various xenomorph-based acids with complex organ-like thing. We assume, that thing is responsible for producing weeds nearby."
	id = RESEARCH_XENO_SACK
	req_tech = list(RESEARCH_XENO_FLORA)

/datum/marineTech/XenoDrone
	name = "Drone resin secrete"
	desc = "Analysis of various patterns of Drone's secrete glands"
	resdesc = "Drone is a true enigma. Let's take their secrete glands. Gland, that produces resin. Highly complex and unbelievably small, those glands can rapidly put sacks anywhere. Only one question is unanswered - where does it takes energy for that?"
	id = RESEARCH_XENO_DRONE
	req_tech = list(RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_FLORA)


//Xenopsi path
/datum/marineTech/XenoMind
	name = "Xenomorph Psionics"
	desc = "Analysis of telepathic connections between members of Xenohive"
	resdesc = "Psionics now are no mistery. Xenomorphs have telepathy, but most of them only recieving signals. But our dear Queeny is center of this network! She is responsible for unity inside the Hive! She is commanding Xenomophs Forces! But NO MORE! And her death will be demise for every xeno that had been controlled by her will!"
	id = RESEARCH_XENO_QUEEN
	time = 60
	req_tech = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_CHEMISTRY)

/datum/marineTech/Disruptor			// Fun starting here
	name = "Hivelink disruption"
	desc = "Finding ways to disrupt psionic link between members of the Hive."
	resdesc = "It was bit of surprise, when we finally get an intresting way to make xenomorphs a little pain. We don't even need Queen's core to create it. Just a little messing with electromagnetic fields and bunch of surplus equipment will make enemy regret."
	id = RESEARCH_XENO_DISRUPTION
	time = 120
	req_tech = list(RESEARCH_XENO_QUEEN)
	need_item = 0
/
/datum/marineTech/Corruption			// "- Absolute DISGUSTING!"- says xenomorph
	name = "Hivemind corruption."
	desc = "Finding ways to twist and create new Hives."
	resdesc = "Some unorthodox solution for wiping out our enemy is found. We basically creating our own loyal Hive. Let's just hope, that our new \"friends\" can fit in our containment cells. But be advised, gene-agent is highly unstable and can cause unpredictable consequences."
	id = RESEARCH_XENO_CORRUPTION
	time = 150
	req_tech = list(RESEARCH_XENO_DISRUPTION, RESEARCH_XENO_DRONE, RESEARCH_XENO_SACK, RESEARCH_XENO_SPITTER)
	need_item = 0


/////////
//Disk
/////////
/obj/item/research_disk
	name = "W-Y Brand disk"
	icon = 'icons/obj/items/disk.dmi'
	icon_state = "datadisk4"
	w_class = 1.0
	var/list/teches = list()

/obj/item/research_disk/upp				//UPP survivor
	icon_state = "datadisk0"

/obj/item/research_disk/upp/New()
	..()
	teches = list(RESEARCH_XENOSTART, RESEARCH_XENO_BIOLOGY, RESEARCH_XENO_FLORA)
	if(prob(50))
		teches += RESEARCH_BIO_PLATING
		teches += RESEARCH_XENO_MUSCLES
	if(prob(50))
		teches += RESEARCH_XENO_WEED
		teches += RESEARCH_XENO_SACK
	if(prob(10))
		teches += RESEARCH_XENO_CHEMISTRY
	if(prob(20))
		teches += RESEARCH_XENO_DRONE
