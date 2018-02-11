/obj/item/storage/surgical_tray
	name = "surgical tray"
	desc = "A small metallic tray covered in sterile tarp. Intended to store surgical tools in a neat and clean fashion."
	icon_state = "surgical_tray"
	flags_atom = FPRINT|CONDUCT
	w_class = 4 //Should not fit in backpacks
	storage_slots = 10
	max_storage_space = 20
	can_hold = list("/obj/item/tool/surgery")

	New()
		..()
		new /obj/item/tool/surgery/scalpel/manager(src)
		new /obj/item/tool/surgery/scalpel(src)
		new /obj/item/tool/surgery/hemostat(src)
		new /obj/item/tool/surgery/retractor(src)
		new /obj/item/tool/surgery/cautery(src)
		new /obj/item/tool/surgery/circular_saw(src)
		new /obj/item/tool/surgery/surgicaldrill(src)
		new /obj/item/tool/surgery/bonegel(src)
		new /obj/item/tool/surgery/bonesetter(src)
		new /obj/item/tool/surgery/FixOVein(src)

/obj/item/storage/surgical_tray/update_icon()
	if(!contents.len)
		icon_state = "surgical_tray_e"
	else
		icon_state = "surgical_tray"
