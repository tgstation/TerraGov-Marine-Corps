/obj/item/storage/surgical_tray
	name = "surgical tray"
	desc = "A small metallic tray covered in sterile tarp. Intended to store surgical tools in a neat and clean fashion."
	icon_state = "surgical_tray"
	flags_atom = CONDUCT
	w_class = WEIGHT_CLASS_BULKY //Should not fit in backpacks
	storage_slots = 12
	max_storage_space = 24
	can_hold = list(
		/obj/item/tool/surgery,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/stack/nanopaste,
	)
	spawns_with = list(
		/obj/item/tool/surgery/scalpel/manager,
		/obj/item/tool/surgery/scalpel,
		/obj/item/tool/surgery/hemostat,
		/obj/item/tool/surgery/retractor,
		/obj/item/stack/medical/advanced/bruise_pack,
		/obj/item/tool/surgery/cautery,
		/obj/item/tool/surgery/circular_saw,
		/obj/item/tool/surgery/surgicaldrill,
		/obj/item/tool/surgery/bonegel,
		/obj/item/tool/surgery/bonesetter,
		/obj/item/tool/surgery/FixOVein,
		/obj/item/stack/nanopaste,
	)

/obj/item/storage/surgical_tray/update_icon_state()
	if(!contents.len)
		icon_state = "surgical_tray_e"
	else
		icon_state = "surgical_tray"
