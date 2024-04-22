/obj/item/chromosome
	name = "blank chromosome"
	icon = 'icons/obj/chromosomes.dmi'
	icon_state = ""
	desc = ""
	force = 0
	w_class = WEIGHT_CLASS_SMALL

	var/stabilizer_coeff = 1 //lower is better, affects genetic stability
	var/synchronizer_coeff = 1 //lower is better, affects chance to backfire
	var/power_coeff = 1 //higher is better, affects "strength"
	var/energy_coeff = 1 //lower is better. affects recharge time

	var/cweight = 5

/obj/item/chromosome/proc/can_apply(datum/mutation/human/HM)
	if(!HM || !(HM.can_chromosome == CHROMOSOME_NONE))
		return FALSE
	if((stabilizer_coeff != 1) && (HM.stabilizer_coeff != -1)) //if the chromosome is 1, we dont change anything. If the mutation is -1, we cant change it. sorry
		return TRUE
	if((synchronizer_coeff != 1) && (HM.synchronizer_coeff != -1))
		return TRUE
	if((power_coeff != 1) && (HM.power_coeff != -1))
		return TRUE
	if((energy_coeff != 1) && (HM.energy_coeff != -1))
		return TRUE

/obj/item/chromosome/proc/apply(datum/mutation/human/HM)
	if(HM.stabilizer_coeff != -1)
		HM.stabilizer_coeff = stabilizer_coeff
	if(HM.synchronizer_coeff != -1)
		HM.synchronizer_coeff = synchronizer_coeff
	if(HM.power_coeff != -1)
		HM.power_coeff = power_coeff
	if(HM.energy_coeff != -1)
		HM.energy_coeff = energy_coeff
	HM.can_chromosome = 2
	HM.chromosome_name = name
	HM.modify()
	qdel(src)

/proc/generate_chromosome()
	var/static/list/chromosomes
	if(!chromosomes)
		chromosomes = list()
		for(var/A in subtypesof(/obj/item/chromosome))
			var/obj/item/chromosome/CM = A
			if(!initial(CM.cweight))
				break
			chromosomes[A] = initial(CM.cweight)
	return pickweight(chromosomes)


/obj/item/chromosome/stabilizer
	name = "stabilizer chromosome"
	desc = ""
	icon_state = "stabilizer"
	stabilizer_coeff = 0.8


/obj/item/chromosome/synchronizer
	name = "synchronizer chromosome"
	desc = ""
	icon_state = "synchronizer"
	synchronizer_coeff = 0.5

/obj/item/chromosome/power
	name = "power chromosome"
	desc = ""
	icon_state = "power"
	power_coeff = 1.5

/obj/item/chromosome/energy
	name = "energetic chromosome"
	desc = ""
	icon_state = "energy"
	energy_coeff = 0.5

/obj/item/chromosome/reinforcer
	name = "reinforcement chromosome"
	desc = ""
	icon_state = "reinforcer"


/obj/item/chromosome/reinforcer/can_apply(datum/mutation/human/HM)
	if(!HM || !(HM.can_chromosome == CHROMOSOME_NONE))
		return FALSE
	return !HM.mutadone_proof

/obj/item/chromosome/reinforcer/apply(datum/mutation/human/HM)
	HM.mutadone_proof = TRUE
	..()
