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
	desc = "This packet containts tricordazine pills. Heals all types of damage slightly. Once you take them out they don't go back in. No more than 2 pills in a short period."
	pill_type_to_fill = /obj/item/reagent_containers/pill/tricordrazine
	storage_slots = 6
	max_storage_space = 6

/obj/item/storage/pill_bottle/packet/paracetamol
	name = "Paracematol pill packet"
	desc = "This packet containts paracetamol pills, also known as tylenol. A long lasting but minor painkiller. Once you take them out they don't go back in. No more than 4 pills in a long period."
	pill_type_to_fill = /obj/item/reagent_containers/pill/paracetamol

/obj/item/storage/pill_bottle/packet/leporazine
	name = "Leporazine pill packet"
	desc = "This packet containts leporazine pills. Rapidly stablizes the patients internal temperature. Once you take them out they don't go back in.."
	pill_type_to_fill = /obj/item/reagent_containers/pill/leporazine

/obj/item/storage/pill_bottle/packet/russian_red
	name = "Russian Red pill packet"
	desc = "This packet containts Russian Red pills. Used for field treatment of critical cases without a medic. Once you take them out they don't go back in.."
	pill_type_to_fill = /obj/item/reagent_containers/pill/russian_red

/obj/item/storage/pill_bottle/packet/ryetalyn
	name = "Ryetalyn pill packet"
	desc = "This packet containts Ryetalyn pills. Used to provide a shield against bloodstream toxins. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/ryetalyn

/obj/item/storage/pill_bottle/packet/bicaridine
	name = "bicaridine pill packet"
	desc = "This packet containts bicaridine pills. Used to treat minor lacerations. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/bicaridine
	storage_slots = 8
	max_storage_space = 8

/obj/item/storage/pill_bottle/packet/kelotane
	name = "kelotane pill packet"
	desc = "This packet containts kelotane pills. Used to treat surface burns. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/kelotane
	storage_slots = 8
	max_storage_space = 8

/obj/item/storage/pill_bottle/packet/tramadol
	name = "tramadol pill packet"
	desc = "This packet containts tramadol pills. Used as a medium-strength painkiller. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/tramadol
	storage_slots = 8
	max_storage_space = 8
