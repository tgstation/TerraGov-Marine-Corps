/datum/component/decal/blood
	dupe_mode = COMPONENT_DUPE_UNIQUE

/datum/component/decal/blood/Initialize(_icon, _icon_state, _dir, _cleanable=CLEAN_STRENGTH_BLOOD, _color, _layer=ABOVE_OBJ_LAYER)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_GET_EXAMINE_NAME, .proc/get_examine_name)

/datum/component/decal/blood/generate_appearance(_icon, _icon_state, _dir, _layer, _color)
	testing("genappearance")
	var/obj/item/I = parent
	if(I.bigboy)
		if(!_icon)
			_icon = 'icons/effects/bloodbig.dmi'
		if(!_icon_state)
			_icon_state = "itemblood"
	else
		if(!_icon)
			_icon = 'icons/effects/blood.dmi'
		if(!_icon_state)
			_icon_state = "splatter[rand(1,6)]"
	var/icon = I.icon
	var/icon_state = I.icon_state
	var/static/list/blood_splatter_appearances = list()
	//try to find a pre-processed blood-splatter. otherwise, make a new one
	var/index = "[REF(icon)]-[icon_state]"
	pic = blood_splatter_appearances[index]

	if(!pic)
		var/icon/blood_splatter_icon = icon(I.icon, I.icon_state, , 1)		//we only want to apply blood-splatters to the initial icon_state for each object
		blood_splatter_icon.Blend("#fff", ICON_ADD) 			//fills the icon_state with white (except where it's transparent)
		blood_splatter_icon.Blend(icon(_icon, _icon_state), ICON_MULTIPLY) //adds blood and the remaining white areas become transparant
		pic = mutable_appearance(blood_splatter_icon, initial(I.icon_state))
		blood_splatter_appearances[index] = pic
	pic.alpha = 150
	return TRUE

/datum/component/decal/blood/proc/get_examine_name(datum/source, mob/user, list/override)
	var/atom/A = parent
	override[EXAMINE_POSITION_ARTICLE] = A.gender == PLURAL? "some" : "a"
	override[EXAMINE_POSITION_BEFORE] = " <span class='danger'>bloody</span> "
	return COMPONENT_EXNAME_CHANGED
