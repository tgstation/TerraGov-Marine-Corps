/obj/item/phone
	name = "red phone"
	desc = "Should anything ever go wrong..."
	icon = 'icons/obj/items/items.dmi'
	icon_state = "red_phone"
	force = 3
	throwforce = 2
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("called", "rang")
	hitsound = 'sound/weapons/ring.ogg'

/obj/item/clock
	name = "digital clock"
	desc = "A battery powered clock, able to keep time within about 5 seconds... it was never that accurate."
	icon = 'icons/obj/device.dmi'
	icon_state = "digital_clock"
	force = 3
	throwforce = 2
	throw_speed = 1
	throw_range = 4
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clock/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += "The [src] reads: [GLOB.current_date_string] - [stationTimestamp()]"

/obj/item/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	icon = 'icons/obj/items/harvest.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 4
	throw_range = 20

/obj/item/bananapeel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 0.4 SECONDS, 0.2 SECONDS)

/obj/item/gift
	name = "gift"
	desc = "A wrapped item."
	icon = 'icons/obj/items/items.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/containers_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/containers_right.dmi',
	)
	icon_state = "gift3"
	var/size = 3
	var/obj/item/gift = null
	item_state = "gift"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/staff
	name = "wizards staff"
	desc = "Apparently a staff used by the wizard."
	icon = 'icons/obj/wizard.dmi'
	item_icons = list(
		slot_l_hand_str = 'icons/mob/inhands/items/toys_left.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items/toys_right.dmi',
	)
	icon_state = "staff"
	force = 3
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("bludgeoned", "whacked", "disciplined")

/obj/item/staff/broom
	name = "broom"
	desc = "Used for sweeping, and flying into the night while cackling. Black cat not included."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "broom"

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
	/// Used to determine the type of upgrade the miner is going to receive. Has to be a string which is defined in miner.dm or it won't work.
	var/uptype

/obj/item/minerupgrade/reinforcement
	name = "reinforced components box"
	desc = "A very folded box of reinforced components, meant to replace weak components used in normal mining wells."
	icon_state = "mining_drill_reinforceddisplay"
	uptype = "reinforced components"

/obj/item/minerupgrade/overclock
	name = "high-efficiency drill"
	desc = "A box with a few pumps and a big drill, meant to replace the standard drill used in normal mining wells for faster extraction."
	icon_state = "mining_drill_overclockeddisplay"
	uptype = "high-efficiency drill"

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
