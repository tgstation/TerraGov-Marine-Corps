/obj/item/phone
	name = "red phone"
	desc = "Should anything ever go wrong..."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "red_phone"
	force = 3.0
	throwforce = 2.0
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("called", "rang")
	hitsound = 'sound/weapons/ring.ogg'

/obj/item/clock
	name = "digital clock"
	desc = "A battery powered clock, able to keep time within about 5 seconds... it was never that accurate."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "digital_clock"
	force = 3.0
	throwforce = 2.0
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clock/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += "The [src] reads: [GLOB.current_date_string] - [stationTimestamp()]"

/obj/item/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 20

/obj/item/bananapeel/Initialize()
	. = ..()
	var/static/list/connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_cross,
	)
	AddElement(/datum/element/connect_loc, connections)

/obj/item/bananapeel/proc/on_cross(datum/source, atom/movable/AM, oldloc, oldlocs) //TODO JUST USE THE SLIPPERY COMPONENT
	if (iscarbon(AM))
		var/mob/living/carbon/C = AM
		C.slip(name, 4, 2)

/obj/item/cane
	name = "cane"
	desc = "A cane used by a true gentlemen. Or a clown."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "cane"
	item_state = "stick"
	flags_atom = CONDUCT
	force = 5.0
	throwforce = 7.0
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bludgeoned", "whacked", "disciplined", "thrashed")

/obj/item/gift
	name = "gift"
	desc = "A wrapped item."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "gift3"
	var/size = 3.0
	var/obj/item/gift = null
	item_state = "gift"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/staff
	name = "wizards staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "staff"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bludgeoned", "whacked", "disciplined")

/obj/item/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "broom"

/obj/item/staff/gentcane
	name = "Gentlemans Cane"
	desc = "An ebony cane with an ivory tip."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "cane"
	item_state = "stick"

/obj/item/staff/stick
	name = "stick"
	desc = "A great tool to drag someone else's drinks across the bar."
	icon = 'icons/obj/items/weapons.dmi'
	icon_state = "stick"
	item_state = "stick"
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL

/obj/item/skub
	desc = "It's skub."
	name = "skub"
	icon = 'icons/obj/items/items.dmi'
	icon_state = "skub"
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("skubbed")

/obj/item/ectoplasm
	name = "ectoplasm"
	desc = "spooky"
	gender = PLURAL
	icon = 'icons/obj/wizard.dmi'
	icon_state = "ectoplasm"

/obj/item/minerupgrade
	name = "miner upgrade"
	desc = "Subtype item, should not exist."
	icon = 'icons/obj/mining_drill.dmi'
	icon_state = "mining_drill_reinforceddisplay"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/metal = 60000) // 18 Sheets , because thats all a autolathe can fit
	/// Used to determine the type of upgrade the miner is going to receive. Has to be a string which is defined in miner.dm or it won't work.
	var/uptype

/obj/item/minerupgrade/reinforcement
	name = "reinforced components box"
	desc = "A very folded box of reinforced components, meant to replace weak components used in normal mining wells."
	icon_state = "mining_drill_reinforceddisplay"
	uptype = "reinforced components"

/obj/item/minerupgrade/overclock
	name =  "high-efficiency drill"
	desc = "A box with a few pumps and a big drill, meant to replace the standard drill used in normal mining wells for faster extraction."
	icon_state = "mining_drill_overclockeddisplay"
	uptype = "high-efficiency drill"

/obj/item/dropship_points_voucher
	name = "dropship fabricator voucher"
	desc = "A small keycard stamped by a Terra Gov logo. It contains points you can redeem at a dropship fabricator. One use only."
	icon = 'icons/obj/items/card.dmi'
	icon_state = "centcom"
	///This is the number of points this thing has to give.
	var/extra_points = 150

/obj/item/dropship_points_voucher/examine(mob/user)
	. = ..()
	. += "It contains [extra_points] points."

/obj/item/minerupgrade/automatic
	name = "mining computer"
	desc = "A small computer that can automate mining wells, reducing the need for oversight."
	icon_state = "mining_drill_automaticdisplay"
	uptype = "mining computer"

/obj/item/ai_target_beacon
	name = "AI linked remote targeter"
	desc = "A small set of servos and gears, coupled to a battery, antenna and circuitry. Attach it to a mortar to allow a shipborne AI to remotely target it."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "modkit"
