/obj/structure/get_antag_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.antag_text)
		return general_entry.antag_text

/obj/structure/get_lore_info()
	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.lore_text)
		return general_entry.lore_text

/obj/structure/get_mechanics_info()
	var/list/structure_strings = list()

	var/list/entries = SScodex.retrieve_entries_for_string(name)
	var/datum/codex_entry/general_entry = LAZYACCESS(entries, 1)
	if(general_entry && general_entry.mechanics_text)
		structure_strings += general_entry.mechanics_text + "<br>"

	if(climbable)
		structure_strings += "You can climb ontop of this structure."

	if(can_buckle)
		structure_strings += "You can buckle someone or yourself to this structure. <br>Click the structure or press 'resist' to unbuckle."

	if(CHECK_BITFIELD(resistance_flags, LAVA_PROOF))
		structure_strings += "This structure is Lava proof."
	if(CHECK_BITFIELD(resistance_flags, FIRE_PROOF))
		structure_strings += "You cannot set this structure on fire."
	if(CHECK_BITFIELD(resistance_flags, FLAMMABLE))
		structure_strings += "This structure can be set on fire."
	if(CHECK_BITFIELD(resistance_flags, UNACIDABLE))
		structure_strings += "Acid does not stick to or affect this structure at all."
	if(CHECK_BITFIELD(resistance_flags, ACID_PROOF))
		structure_strings += "You can try but cannot melt this structure with acid."
	if(CHECK_BITFIELD(resistance_flags, INDESTRUCTIBLE))
		structure_strings += "You cannot destroy this structure."
	else
		structure_strings += "You can destroy this structure."
	if(CHECK_BITFIELD(resistance_flags, FREEZE_PROOF))
		structure_strings += "You cannot freeze this structure."
						
	if(parts)
		structure_strings += "<U>It is made from the following parts</U>:"
		var/obj/A = parts
		structure_strings += "[initial(A.name)]"

	if(anchored)
		structure_strings += "It is anchored in place."

	. += jointext(structure_strings, "<br>")

/datum/codex_entry/girder
	associated_strings = "girder"
	display_name = "girder"
	mechanics_text = "Use metal sheets on this to build a normal wall.  Adding plasteel instead will make a reinforced wall.<br>\
	A false wall can be made by using a crowbar on this girder, and then adding metal or plasteel.<br>\
	You can dismantle the grider with a wrench."

/datum/codex_entry/grille
	associated_strings = "grille"
	display_name = "grille"
	mechanics_text = "A powered and knotted wire underneath this will cause the grille (provided it is made of a conductive material) to shock anyone not wearing insulated gloves.<br>\
	Wirecutters will turn the grille into rods instantly.  Grilles are typically made with steel rods."

/datum/codex_entry/lattice
	associated_strings = "lattice"
	display_name = "lattice"
	mechanics_text = "Add a metal floor tile to build a floor on top of the lattice.<br>\
	Lattices can be made by applying rods to a space tile."

/datum/codex_entry/bed
	associated_strings = "bed"
	display_name = "bed"
	lore_text = "This bed was made by the only bed manufacturer remaining (Onlybed Manufacturing) after the big event. You would call it 'average' at best."
	mechanics_text = "Click and drag yourself (or anyone) to this bed to buckle in. Click on this bed with an empty hand, or press the 'resist' button, to undo the buckles.<br>\
	<br>\
	Anyone with restraints, such as handcuffs, will not be able to unbuckle themselves. They must use the Resist button, or verb, to break free of \
	the buckles, instead."