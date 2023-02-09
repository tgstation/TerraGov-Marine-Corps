// Pill packets, basically pill bottles you can't put pills back into.

/obj/item/storage/pill_bottle/packet
	name = "Pill packet"
	desc = "Contains pills. Once you take them out they don't go back in."
	icon_state = "pills_8"
	cant_hold = list(/obj/item/reagent_containers/pill) //Nada. Once you take the pills out. They don't come back in.
	storage_slots = 8
	max_w_class = 0
	max_storage_space = 8
	greyscale_config = /datum/greyscale_config/pillpacket
	greyscale_colors = "#EAEAEA#0066ff" //default colors
	///the item left behind when this is used up
	var/trash_item = /obj/item/trash/pillpacket
	///Amount of pills removed from the packet
	var/pills_removed = 0
	refill_types = null
	refill_sound = null

/obj/item/storage/pill_bottle/packet/update_icon()
	icon_state = "pills_[8-pills_removed]"

/obj/item/storage/pill_bottle/packet/remove_from_storage(obj/item/item, atom/new_location, mob/user)
	. = ..()
	pills_removed += 1
	update_icon()
	if(. && !contents.len && !gc_destroyed)
		var/turf/T = get_turf(src)
		new trash_item(T)
		qdel(src)

/obj/item/storage/pill_bottle/packet/bicaridine
	name = "Bicaridine pill packet"
	desc = "This packet contains bicaridine pills. Used to treat minor lacerations. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/bicaridine
	greyscale_colors = "#EAEAEA#952F48"

/obj/item/storage/pill_bottle/packet/kelotane
	name = "Kelotane pill packet"
	desc = "This packet contains kelotane pills. Used to treat surface burns. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/kelotane
	greyscale_colors = "#EAEAEA#BD8854"

/obj/item/storage/pill_bottle/packet/tramadol
	name = "Tramadol pill packet"
	desc = "This packet contains tramadol pills. Used as a medium-strength painkiller. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/tramadol
	greyscale_colors = "#EAEAEA#675772"

/obj/item/storage/pill_bottle/packet/tricordrazine
	name = "Tricordazine pill packet"
	desc = "This packet contains tricordazine pills. Heals all types of damage slightly. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/tricordrazine
	greyscale_colors = "#EAEAEA#FFFFFF"

/obj/item/storage/pill_bottle/packet/dylovene
	name = "Dylovene pill packet"
	desc = "This packet contains dylovene pills. Used to purge toxins and heal toxic damage. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/dylovene
	greyscale_colors = "#EAEAEA#2DA54B"

/obj/item/storage/pill_bottle/packet/paracetamol
	name = "Paracematol pill packet"
	desc = "This packet contains paracetamol pills, also known as tylenol. A long lasting but minor painkiller. Once you take them out they don't go back in. No more than 4 pills in a long period."
	pill_type_to_fill = /obj/item/reagent_containers/pill/paracetamol
	greyscale_colors = "#EAEAEA#65B4B1"

/obj/item/storage/pill_bottle/packet/leporazine
	name = "Leporazine pill packet"
	desc = "This packet contains leporazine pills. Rapidly stablizes the patients internal temperature. Once you take them out they don't go back in.."
	pill_type_to_fill = /obj/item/reagent_containers/pill/leporazine
	greyscale_colors = "#EAEAEA#0066FF"

/obj/item/storage/pill_bottle/packet/russian_red
	name = "Russian Red pill packet"
	desc = "This packet contains Russian Red pills. Used for field treatment of critical cases without a medic. Once you take them out they don't go back in.."
	pill_type_to_fill = /obj/item/reagent_containers/pill/russian_red
	greyscale_colors = "#EAEAEA#3d0000"

/obj/item/storage/pill_bottle/packet/ryetalyn
	name = "Ryetalyn pill packet"
	desc = "This packet contains Ryetalyn pills. Used to provide a shield against bloodstream toxins. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/ryetalyn
	greyscale_colors = "#EAEAEA#AC6D32"
