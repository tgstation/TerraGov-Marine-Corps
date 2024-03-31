/datum/mutation/human/geladikinesis
	name = "Geladikinesis"
	desc = ""
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>My hand feels cold.</span>"
	instability = 10
	difficulty = 10
	synchronizer_coeff = 1
	power = /obj/effect/proc_holder/spell/targeted/conjure_item/snow

/obj/effect/proc_holder/spell/targeted/conjure_item/snow
	name = "Create Snow"
	desc = ""
	item_type = /obj/item/stack/sheet/mineral/snow
	charge_max = 50
	delete_old = FALSE
	action_icon_state = "snow"


/datum/mutation/human/cryokinesis
	name = "Cryokinesis"
	desc = ""
	quality = POSITIVE //upsides and downsides
	text_gain_indication = "<span class='notice'>My hand feels cold.</span>"
	instability = 20
	difficulty = 12
	synchronizer_coeff = 1
	power = /obj/effect/proc_holder/spell/aimed/cryo

/obj/effect/proc_holder/spell/aimed/cryo
	name = "Cryobeam"
	desc = ""
	charge_max = 150
	cooldown_min = 150
	clothes_req = FALSE
	range = 3
	projectile_type = /obj/projectile/temp/cryo
	base_icon_state = "icebeam"
	action_icon_state = "icebeam"
	active_msg = "You focus my cryokinesis!"
	deactive_msg = "You relax."
	active = FALSE

