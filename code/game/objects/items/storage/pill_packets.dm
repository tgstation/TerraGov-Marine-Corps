// Pill packets, basically pill bottles you can't put pills back into.

/obj/item/storage/pill_bottle/packet
	name = "Pill packet"
	desc = "Containts pills. Once you take them out they don't go back in."
	icon_state = "pill_packet"
	cant_hold = list(/obj/item/reagent_containers/pill) //Nada. Once you take the pills out. They don't come back in.
	storage_slots = 4
	max_w_class = 0
	max_storage_space = 4

/obj/item/storage/pill_bottle/packet/tricordrazine
	name = "Tricordazine pill packet"
	desc = "This packet containts tricordazine pills. Heals all types of damage minorly. Once you take them out they don't go back in. No more than 2 pills in a short period."
	pill_type_to_fill = /obj/item/reagent_containers/pill/tricordrazine

/obj/item/storage/pill_bottle/packet/paracetamol
	name = "Paracematol pill packet"
	desc = "This packet containts paracetamol pills, also known as tylenol. A long lasting but minor painkiller. Once you take them out they don't go back in. No more than 4 pills in a long period."
	pill_type_to_fill = /obj/item/reagent_containers/pill/paracetamol

