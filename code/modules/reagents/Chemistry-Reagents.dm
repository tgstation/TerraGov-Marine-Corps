
//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.


/datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = SOLID
	var/list/data = null
	var/volume = 0
	var/nutriment_factor = 0
	var/custom_metabolism = REAGENTS_METABOLISM
	var/overdose = 0 //The young brother of overdose. Side effects include
	var/overdose_critical = 0 //The nastier brother of overdose. Expect to die
	var/overdose_dam = 1//Handeled by heart damage
	var/scannable = 0 //shows up on health analyzers
	var/spray_warning = FALSE //whether spraying that reagent creates an admin message.
	//var/list/viruses = list()
	var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)

/datum/reagent/proc/reaction_mob(var/mob/M, var/method=TOUCH, var/volume) //By default we have a chance to transfer some
	if(!istype(M, /mob/living))	return 0
	var/datum/reagent/self = src
	src = null										  //of the reagent to the mob on TOUCHING it.

	if(self.holder)		//for catching rare runtimes
		if(!istype(self.holder.my_atom, /obj/effect/particle_effect/smoke/chem))
			// If the chemicals are in a smoke cloud, do not try to let the chemicals "penetrate" into the mob's system (balance station 13) -- Doohl

			if(method == TOUCH)

				var/chance = 1
				var/block  = 0

				for(var/obj/item/clothing/C in M.get_equipped_items())
					if(C.permeability_coefficient < chance) chance = C.permeability_coefficient
					if(istype(C, /obj/item/clothing/suit/bio_suit))
						// bio suits are just about completely fool-proof - Doohl
						// kind of a hacky way of making bio suits more resistant to chemicals but w/e
						if(prob(75))
							block = 1

					if(istype(C, /obj/item/clothing/head/bio_hood))
						if(prob(75))
							block = 1

				chance = chance * 100

				if(prob(chance) && !block)
					if(M.reagents)
						M.reagents.add_reagent(self.id,self.volume/2)
	return 1

/datum/reagent/proc/reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
	src = null						//if it can hold reagents. nope!
	//if(O.reagents)
	//	O.reagents.add_reagent(id,volume/3)
	return

/datum/reagent/proc/reaction_turf(var/turf/T, var/volume)
	src = null
	return

/datum/reagent/proc/on_mob_life(mob/living/M, alien)
	if((!isliving(M) || alien == IS_HORROR)) return //Noticed runtime errors from pacid trying to damage ghosts, this should fix. --NEO
	//We do not horrors to metabolize anything.
	holder.remove_reagent(id, custom_metabolism) //By default it slowly disappears.
	if(overdose && volume >= overdose)
		on_overdose(M, alien) //Small OD

	if(overdose_critical && volume > overdose_critical)
		on_overdose_critical(M, alien) //Big OD
	return 1

/datum/reagent/proc/on_overdose(mob/living/M, alien)
	return

/datum/reagent/proc/on_overdose_critical(mob/living/M, alien)
	return

/datum/reagent/proc/on_move(var/mob/M)
	return

	// Called after add_reagents creates a new reagent.
/datum/reagent/proc/on_new(var/data)
	return

/datum/reagent/proc/on_update(var/atom/A)
	return
