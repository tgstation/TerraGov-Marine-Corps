// Pill packets, basically pill bottles you can't put pills back into.

/obj/item/storage/pill_bottle/packet
	name = "pill packet"
	desc = "Contains pills. Once you take them out they don't go back in."
	icon_state = "packet_canister"
	cant_hold = list(/obj/item/reagent_containers/pill) //Nada. Once you take the pills out. They don't come back in.
	storage_slots = 8
	max_w_class = 0
	max_storage_space = 8
	greyscale_config = null //So that we get packets and not pill bottles.
	///Color of the pips on top of the pill packet
	var/pip_color = "#0066ff" //default color because I like this color
	///the item left behind when this is used up
	var/trash_item = /obj/item/trash/pillpacket
	refill_types = null
	refill_sound = null
	flags_storage = BYPASS_VENDOR_CHECK

/obj/item/storage/pill_bottle/packet/remove_from_storage(obj/item/item, atom/new_location, mob/user)
	. = ..()
	if(!.)
		return
	if(!length(contents) && !QDELETED(src))
		var/turf/T = get_turf(src)
		new trash_item(T)
		qdel(src)
		return
	update_icon()

/obj/item/storage/pill_bottle/packet/update_overlays()
	. = ..()
	var/image/overlay = image('icons/obj/items/chemistry.dmi', src, "packet_canister[length(contents)]")
	overlay.color = pip_color
	. += overlay

/obj/item/storage/pill_bottle/packet/bicaridine
	name = "bicaridine pill packet"
	desc = "This packet contains bicaridine pills. Used to treat minor lacerations. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/bicaridine
	pip_color = COLOR_PACKET_BICARIDINE

/obj/item/storage/pill_bottle/packet/kelotane
	name = "kelotane pill packet"
	desc = "This packet contains kelotane pills. Used to treat surface burns. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/kelotane
	pip_color = COLOR_PACKET_KELOTANE

/obj/item/storage/pill_bottle/packet/tramadol
	name = "tramadol pill packet"
	desc = "This packet contains tramadol pills. Used as a medium-strength painkiller. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/tramadol
	pip_color = COLOR_PACKET_TRAMADOL

/obj/item/storage/pill_bottle/packet/tricordrazine
	name = "tricordrazine pill packet"
	desc = "This packet contains tricordrazine pills. Heals all types of damage slightly. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/tricordrazine
	pip_color = COLOR_PACKET_TRICORDRAZINE

/obj/item/storage/pill_bottle/packet/dylovene
	name = "dylovene pill packet"
	desc = "This packet contains dylovene pills. Used to purge toxins and heal toxic damage. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/dylovene
	pip_color = COLOR_PACKET_DYLOVENE

/obj/item/storage/pill_bottle/packet/paracetamol
	name = "paracetamol pill packet"
	desc = "This packet contains paracetamol pills, also known as tylenol. A long lasting but minor painkiller. Once you take them out they don't go back in. No more than 4 pills in a long period."
	pill_type_to_fill = /obj/item/reagent_containers/pill/paracetamol
	pip_color = COLOR_PACKET_PARACETAMOL

/obj/item/storage/pill_bottle/packet/isotonic
	name = "isotonic pill packet"
	desc = "A pill with an isotonic solution inside. Used to stimulate blood regeneration. Once you take them out they don't go back in."
	pill_type_to_fill = /obj/item/reagent_containers/pill/isotonic
	pip_color = COLOR_PACKET_ISOTONIC

/obj/item/storage/pill_bottle/packet/leporazine
	name = "leporazine pill packet"
	desc = "This packet contains leporazine pills. Rapidly stablizes the patients internal temperature. Once you take them out they don't go back in.."
	pill_type_to_fill = /obj/item/reagent_containers/pill/leporazine
	pip_color = COLOR_PACKET_LEPORAZINE

/obj/item/storage/pill_bottle/packet/russian_red
	name = "russian red pill packet"
	desc = "This packet contains Russian Red pills. Used for field treatment of critical cases without a medic. Once you take them out they don't go back in.."
	pill_type_to_fill = /obj/item/reagent_containers/pill/russian_red
	pip_color = COLOR_PACKET_RUSSIAN_RED

/obj/item/storage/pill_bottle/packet/ryetalyn
	name = "ryetalyn pill packet"
	desc = "This packet contains Ryetalyn pills. Used to provide a shield against bloodstream toxins. Once you take them out they don't go back in. No more than 2 pills at once."
	pill_type_to_fill = /obj/item/reagent_containers/pill/ryetalyn
	pip_color = COLOR_PACKET_RYETALYN
