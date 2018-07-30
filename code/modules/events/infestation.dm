#define LOC_CAFETERIA 0
#define LOC_CARGO 1
#define LOC_ENGI_STORAGE 2
#define LOC_MORGUE 3
#define LOC_DISPOSAL 4
#define LOC_MEDBAY_STORAGE 5

#define VERM_MICE 0
#define VERM_LIZARDS 1
#define VERM_SPIDERS 2

/datum/event/infestation
	announceWhen = 10
	endWhen = 11
	var/location
	var/locstring
	var/vermin
	var/vermstring

/datum/event/infestation/start()

	location = rand(0,5)
	var/list/turf/open/floor/turfs = list()
	var/spawn_area_type
	switch(location)
		if(LOC_CAFETERIA)
			spawn_area_type = /area/sulaco/cafeteria
			locstring = "the cafeteria"
		if(LOC_CARGO)
			spawn_area_type = /area/sulaco/cargo
			locstring = "the cargo bay"
		if(LOC_ENGI_STORAGE)
			spawn_area_type = /area/sulaco/engineering/storage
			locstring = "the engineering storage"
		if(LOC_MORGUE)
			spawn_area_type = /area/sulaco/morgue
			locstring = "the morgue"
		if(LOC_DISPOSAL)
			spawn_area_type = /area/sulaco/disposal
			locstring = "disposal"
		if(LOC_MEDBAY_STORAGE)
			spawn_area_type = /area/sulaco/medbay/storage
			locstring = "medbay storage"

	//world << "looking for [spawn_area_type]"
	for(var/areapath in typesof(spawn_area_type))
		//world << "	checking [areapath]"
		var/area/A = locate(areapath)
		//world << "	A: [A], contents.len: [A.contents.len]"
		for(var/area/B in A.related)
			//world << "	B: [B], contents.len: [B.contents.len]"
			for(var/turf/open/floor/F in B.contents)
				if(!F.contents.len)
					turfs += F

	var/list/spawn_types = list()
	var/max_number
	vermin = rand(0,2)
	switch(vermin)
		if(VERM_MICE)
			spawn_types = list(/mob/living/simple_animal/mouse/gray, /mob/living/simple_animal/mouse/brown, /mob/living/simple_animal/mouse/white)
			max_number = 12
			vermstring = "mice"
		if(VERM_LIZARDS)
			spawn_types = list(/mob/living/simple_animal/lizard)
			max_number = 6
			vermstring = "lizards"
		if(VERM_SPIDERS)
			spawn_types = list(/obj/effect/spider/spiderling)
			max_number = 3
			vermstring = "spiders"

	spawn(0)
		var/num = rand(2,max_number)
		while(turfs.len > 0 && num > 0)
			var/turf/open/floor/T = pick(turfs)
			turfs.Remove(T)
			num--

			if(vermin == VERM_SPIDERS)
				var/obj/effect/spider/spiderling/S = new(T)
				S.amount_grown = -1
			else
				var/spawn_type = pick(spawn_types)
				new spawn_type(T)


/datum/event/infestation/announce()
	command_announcement.Announce("Bioscans indicate that [vermstring] have been breeding in [locstring]. Clear them out, before this starts to affect productivity.", "Vermin infestation")

#undef LOC_CAFETERIA
#undef LOC_CARGO
#undef LOC_ENGI_STORAGE
#undef LOC_MORGUE
#undef LOC_DISPOSAL
#undef LOC_MEDBAY_STORAGE

#undef VERM_MICE
#undef VERM_LIZARDS
#undef VERM_SPIDERS