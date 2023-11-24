/obj/item/factory_refill
	name = "generic refiller"
	desc = "you shouldnt be seeing this."
	icon = 'icons/obj/factory/factoryparts.dmi'
	icon_state = "refillbox"
	///Typepath for the output machine we want to be ejecting
	var/obj/item/factory_part/refill_type = /obj/item/factory_part
	///By how much we wan to refill the target machine
	var/refill_amount = 30

/obj/item/factory_refill/Initialize(mapload)
	. = ..()
	var/obj/path = initial(refill_type.result)
	var/matrix/shift = matrix().Scale(0.4,0.4)
	var/image/result_image = image(initial(path.icon), initial(path.icon_state), pixel_x = 6, pixel_y = -6)
	result_image.transform = shift
	add_overlay(result_image)

/obj/item/factory_refill/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += "It has [refill_amount] packages remaining."

/obj/machinery/unboxer
	name = "Unboxer"
	desc = "An industrial resourcing unboxer."
	icon = 'icons/obj/factory/factory_machines.dmi'
	icon_state = "unboxer_inactive"
	resistance_flags = XENO_DAMAGEABLE
	density = TRUE
	anchored = FALSE
	///the amount of resouce we have left to output factory_parts
	var/production_amount_left = 0
	///Maximum amount of resource we can hold
	var/max_fill_amount = 100
	///Typepath for the result we want outputted
	var/obj/item/factory_part/production_type = /obj/item/factory_part
	///Bool for whether the unboxer is producing things
	var/on = FALSE

/obj/machinery/unboxer/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "direction_arrow"))

/obj/machinery/unboxer/examine(mob/user, distance, infix, suffix)
	. = ..()
	. += "It is currently facing [dir2text(dir)], and is outputting [initial(production_type.name)]. It has [production_amount_left] resources remaining."

/obj/machinery/unboxer/wrench_act(mob/living/user, obj/item/I)
	anchored = !anchored
	balloon_alert(user, "[anchored ? "" : "un"]anchored")

/obj/machinery/unboxer/screwdriver_act(mob/living/user, obj/item/I)
	setDir(turn(dir, 90))
	balloon_alert(user, "Facing [dir2text(dir)]")

/obj/machinery/unboxer/update_icon_state()
	if(datum_flags & DF_ISPROCESSING)
		icon_state = "unboxer"
		return
	icon_state = "unboxer_inactive"

/obj/machinery/unboxer/attack_hand(mob/living/user)
	if(!anchored)
		balloon_alert(user, "Must be anchored!")
		return
	change_state()

///Turns the unboxer on/off
/obj/machinery/unboxer/proc/change_state()
	on = !on
	if(on)
		START_PROCESSING(SSmachines, src)
		balloon_alert_to_viewers("turns on!")
	else
		STOP_PROCESSING(SSmachines, src)
		balloon_alert_to_viewers("turns off!")
	update_icon()

/obj/machinery/unboxer/attack_ai(mob/living/silicon/ai/user)
	return attack_hand(user)

/obj/machinery/unboxer/process()
	if(production_amount_left <= 0)
		change_state()
		return
	new production_type(get_step(src, dir))
	production_amount_left--

/obj/machinery/unboxer/attackby(obj/item/I, mob/living/user, def_zone)
	if(!isfactoryrefill(I) || user.a_intent == INTENT_HARM)
		return ..()
	var/obj/item/factory_refill/refill = I
	if(refill.refill_type != production_type)
		if(production_amount_left)
			balloon_alert(user, "Filler incompatible")
			return
		production_type = refill.refill_type
	var/to_refill = min(max_fill_amount - production_amount_left, refill.refill_amount)
	production_amount_left += to_refill
	refill.refill_amount -= to_refill
	visible_message(span_notice("[user] restocks \the [src] with \the [refill]!"), span_notice("You restock \the [src] with [refill]!"))
	if(!on)
		change_state()
	if(refill.refill_amount <= 0)
		qdel(refill)
		new /obj/item/stack/sheet/metal(user.loc)//simulates leftover trash

/obj/item/factory_refill/phosnade_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/phosnade
	refill_amount = 25

/obj/item/factory_refill/bignade_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/bignade

/obj/item/factory_refill/pizza_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/pizza

/obj/item/factory_refill/sadar_wp_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/sadar_wp
	refill_amount = 15

/obj/item/factory_refill/sadar_ap_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/sadar_ap
	refill_amount = 15

/obj/item/factory_refill/sadar_he_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/sadar_he
	refill_amount = 15

/obj/item/factory_refill/sadar_he_unguided_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/sadar_unguided
	refill_amount = 15

/obj/item/factory_refill/light_rr_missile_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/light_rr_missile
	refill_amount = 15

/obj/item/factory_refill/normal_rr_missile_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/normal_rr_missile
	refill_amount = 15

/obj/item/factory_refill/heat_rr_missile_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/heat_rr_missile
	refill_amount = 15

/obj/item/factory_refill/smoke_rr_missile_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/smoke_rr_missile
	refill_amount = 15

/obj/item/factory_refill/cloak_rr_missile_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/cloak_rr_missile
	refill_amount = 15

/obj/item/factory_refill/tfoot_rr_missile_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/tfoot_rr_missile
	refill_amount = 15

/obj/item/factory_refill/claymore_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/claymore

/obj/item/factory_refill/smartgunner_minigun_box_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/smartgunner_minigun_box
	refill_amount = 10

/obj/item/factory_refill/smartgunner_machinegun_magazine_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/smartgunner_machinegun_magazine
	refill_amount = 10

/obj/item/factory_refill/smartgunner_targetrifle_magazine_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/smartgunner_targetrifle_magazine
	refill_amount = 20

/obj/item/factory_refill/auto_sniper_magazine_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/auto_sniper_magazine

/obj/item/factory_refill/scout_rifle_magazine_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/scout_rifle_magazine
	refill_amount = 20

/obj/item/factory_refill/mateba_speedloader_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/mateba_speedloader

/obj/item/factory_refill/railgun_magazine_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/railgun_magazine
	refill_amount = 20

/obj/item/factory_refill/minigun_powerpack_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/minigun_powerpack
	refill_amount = 10

/obj/item/factory_refill/razornade_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/razornade
	refill_amount = 30

/obj/item/factory_refill/amr_magazine_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/amr_magazine
	refill_amount = 20

/obj/item/factory_refill/amr_magazine_incend_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/amr_magazine_incend
	refill_amount = 20

/obj/item/factory_refill/amr_magazine_flak_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/amr_magazine_flak
	refill_amount = 20

/obj/item/factory_refill/howitzer_shell_he_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/howitzer_shell_he
	refill_amount = 30

/obj/item/factory_refill/howitzer_shell_incen_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/howitzer_shell_incen
	refill_amount = 30

/obj/item/factory_refill/howitzer_shell_wp_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/howitzer_shell_wp
	refill_amount = 30

/obj/item/factory_refill/howitzer_shell_tfoot_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/howitzer_shell_tfoot
	refill_amount = 30

/obj/item/factory_refill/swat_mask_refill
	name = "box of rounded metal plates"
	desc = "A box of round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/swat_mask
	refill_amount = 20

/obj/item/factory_refill/med_advpack_refill
	name = "box of rounded metal plates"
	desc = "A box of round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/med_advpack
	refill_amount = 10

/obj/item/factory_refill/module_valk_refill
	name = "box of rounded metal plates"
	desc = "A box of round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/module_valk
	refill_amount = 10

/obj/item/factory_refill/module_mimir2_refill
	name = "box of rounded metal plates"
	desc = "A box of round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/module_mimir2
	refill_amount = 10

/obj/item/factory_refill/module_tyr2_refill
	name = "box of rounded metal plates"
	desc = "A box of round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/module_tyr2
	refill_amount = 10

/obj/item/factory_refill/module_hlin_refill
	name = "box of rounded metal plates"
	desc = "A box of round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/module_hlin
	refill_amount = 10

/obj/item/factory_refill/module_surt_refill
	name = "box of rounded metal plates"
	desc = "A box of round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/module_surt
	refill_amount = 10

/obj/item/factory_refill/mortar_shell_he_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become High Explosive shells used in mortars, once finished."
	refill_type = /obj/item/factory_part/mortar_shell_he
	refill_amount = 30

/obj/item/factory_refill/mortar_shell_incen_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Incendiary shells used in mortars, once finished."
	refill_type = /obj/item/factory_part/mortar_shell_incen
	refill_amount = 30

/obj/item/factory_refill/mortar_shell_tfoot_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Tanglefoot smoke shells used in mortars, once finished."
	refill_type = /obj/item/factory_part/mortar_shell_tfoot
	refill_amount = 30

/obj/item/factory_refill/mortar_shell_flare_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Flare shells used in mortars, once finished."
	refill_type = /obj/item/factory_part/mortar_shell_flare
	refill_amount = 30

/obj/item/factory_refill/mortar_shell_smoke_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Smoke shells used in mortars, once finished."
	refill_type = /obj/item/factory_part/mortar_shell_flare
	refill_amount = 30

/obj/item/factory_refill/mlrs_rocket_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/mlrs_rocket
	refill_amount = 6

/obj/item/factory_refill/thermobaric_wp_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/thermobaric_wp
	refill_amount = 15

/obj/item/factory_refill/drop_pod_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/drop_pod
	refill_amount = 6
