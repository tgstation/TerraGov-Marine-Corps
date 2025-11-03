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
	balloon_alert(user, "facing [dir2text(dir)]")

/obj/machinery/unboxer/update_icon_state()
	. = ..()
	if(datum_flags & DF_ISPROCESSING)
		icon_state = "unboxer"
		return
	icon_state = "unboxer_inactive"

/obj/machinery/unboxer/attack_hand(mob/living/user)
	if(!anchored)
		balloon_alert(user, "must be anchored!")
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
			balloon_alert(user, "filler incompatible!")
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

/obj/item/factory_refill/bignade_refill
	name = "box of rounded metal plates (M15 Grenade)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become M15 Grenades, once finished."
	refill_type = /obj/item/factory_part/bignade
	refill_amount = 50

/obj/item/factory_refill/incennade_refill
	name = "box of incendiary grenade plates"
	desc = "A box with round metal plates inside that could be used to construct Incendiary genades. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/incennade
	refill_amount = 50

/obj/item/factory_refill/stickynade_refill
	name = "box of adhesive genade plates"
	desc = "A box with round metal plates inside that could be used to construct Adhesive grenades. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/stickynade
	refill_amount = 50

/obj/item/factory_refill/phosnade_refill
	name = "box of white phosphorous grenade plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become White Phosphorous Grenades, once finished."
	refill_type = /obj/item/factory_part/phosnade
	refill_amount = 50

/obj/item/factory_refill/cloaknade_refill
	name = "box of cloaking grenade plates"
	desc = "A box with round metal plates inside that could be used to construct Cloaking grenades. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/cloaknade
	refill_amount = 50

/obj/item/factory_refill/tfootnade_refill
	name = "box of tangle grenade plates"
	desc = "A box with round metal plates inside that could be used to construct Tanglefoot grenades. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/tfootnade
	refill_amount = 50

/obj/item/factory_refill/trailblazer_refill
	name = "box of trailblazer grenade plates"
	desc = "A box with round metal plates inside that could be used to construct Trailblazer genades. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/trailblazer
	refill_amount = 50

/obj/item/factory_refill/lasenade_refill
	name = "box of laser grenade plates and cells."
	desc = "A box with plates and cells inside that could be used to construct Laser grenades. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/lasenade
	refill_amount = 50

/obj/item/factory_refill/hefanade_refill
	name = "box of hefa nade plates and shells."
	desc = "A box with plates and shells inside that could be used to construct HEFA grenades. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/hefanade
	refill_amount = 50

/obj/item/factory_refill/antigas_refill
	name = "box of Anti-Gas plates."
	desc = "A box with plates inside that could be used to construct M40-AG grenades. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/antigas
	refill_amount = 50

/obj/item/factory_refill/razornade_refill
	name = "box of rounded metal plates (Razorburn)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Razorburn Grenades, once finished."
	refill_type = /obj/item/factory_part/razornade
	refill_amount = 50

/obj/item/factory_refill/pizza_refill
	name = "box of rounded metal plates (Pizza)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become 'Pizzas', once finished."
	refill_type = /obj/item/factory_part/pizza

/obj/item/factory_refill/plastique_refill
	name = "box of rounded polymer plates (C4)"
	desc = "A box with round polymer plates inside. Used to refill Unboxers. These will become C4 Charges, once finished."
	refill_type = /obj/item/factory_part/plastique
	refill_amount = 10

/obj/item/factory_refill/plastique_incendiary_refill
	name = "box of rounded polymer plates (EX-62)"
	desc = "A box with round polymer plates inside. Used to refill Unboxers. These will become EX-62 Genghis Incendiary Charges, once finished."
	refill_type = /obj/item/factory_part/plastique_incendiary
	refill_amount = 5

/obj/item/factory_refill/detpack_refill
	name = "box of rounded polymer plates (Detpack)"
	desc = "A box with round polymer plates inside. Used to refill Unboxers. These will become Detpack Charges, once finished."
	refill_type = /obj/item/factory_part/detpack
	refill_amount = 10

/obj/item/factory_refill/sadar_wp_refill
	name = "box of rounded metal plates (SADAR WP)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become White Phosphorous SADAR rockets, once finished."
	refill_type = /obj/item/factory_part/sadar_wp
	refill_amount = 15

/obj/item/factory_refill/sadar_ap_refill
	name = "box of rounded metal plates (SADAR AP)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Armor Piercing SADAR rockets, once finished."
	refill_type = /obj/item/factory_part/sadar_ap
	refill_amount = 15

/obj/item/factory_refill/sadar_he_refill
	name = "box of rounded metal plates (SADAR HE)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become High Explosive SADAR rockets, once finished."
	refill_type = /obj/item/factory_part/sadar_he
	refill_amount = 15

/obj/item/factory_refill/sadar_he_unguided_refill
	name = "box of rounded metal plates (SADAR HE Unguided)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These one become High Explosive Unguided SADAR rockets, once finished."
	refill_type = /obj/item/factory_part/sadar_unguided
	refill_amount = 15

/obj/item/factory_refill/light_rr_missile_refill
	name = "box of rounded metal plates (LE RR shells)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Light Explosive Recoilless shells, once finished."
	refill_type = /obj/item/factory_part/light_rr_missile
	refill_amount = 15

/obj/item/factory_refill/normal_rr_missile_refill
	name = "box of rounded metal plates (HE RR shells)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become High Explosive Recoilless shells, once finished."
	refill_type = /obj/item/factory_part/normal_rr_missile
	refill_amount = 15

/obj/item/factory_refill/heat_rr_missile_refill
	name = "box of rounded metal plates (HEAT RR shells)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become High Explosive Anti-Tank Recoilless shells, once finished."
	refill_type = /obj/item/factory_part/heat_rr_missile
	refill_amount = 15

/obj/item/factory_refill/smoke_rr_missile_refill
	name = "box of rounded metal plates (Smoke RR shells)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Smoke Recoilless shells, once finished."
	refill_type = /obj/item/factory_part/smoke_rr_missile
	refill_amount = 15

/obj/item/factory_refill/cloak_rr_missile_refill
	name = "box of rounded metal plates (Cloak RR shells)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Cloak Recoilless shells, once finished."
	refill_type = /obj/item/factory_part/cloak_rr_missile
	refill_amount = 15

/obj/item/factory_refill/tfoot_rr_missile_refill
	name = "box of rounded metal plates (Tanglefoot RR shells)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Tanglefoot Recoilless shells, once finished."
	refill_type = /obj/item/factory_part/tfoot_rr_missile
	refill_amount = 15

/obj/item/factory_refill/claymore_refill
	name = "box of rounded claymore plates"
	desc = "A box with round claymore plates inside. Used to refill Unboxers. These will become M20 Claymore mines, once finished."
	refill_type = /obj/item/factory_part/claymore

/obj/item/factory_refill/smartgunner_minigun_box_refill
	name = "box of rounded metal plates (SG-85)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become SG-85 Smartgun ammo boxes, once finished."
	refill_type = /obj/item/factory_part/smartgunner_minigun_box
	refill_amount = 10

/obj/item/factory_refill/smartgunner_machinegun_magazine_refill
	name = "box of rounded metal plates (SG-29)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become SG-29 Smartgun magazines, once finished."
	refill_type = /obj/item/factory_part/smartgunner_machinegun_magazine
	refill_amount = 10

/obj/item/factory_refill/smartgunner_targetrifle_magazine_refill
	name = "box of rounded metal plates (SG-62)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become SG-62 Target Rifle magazines, once finished."
	refill_type = /obj/item/factory_part/smartgunner_targetrifle_magazine
	refill_amount = 20

/obj/item/factory_refill/smartgunner_targetrifle_ammobin_refill
	name = "box of rounded metal plates"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/smartgunner_targetrifle_ammobin
	refill_amount = 10

/obj/item/factory_refill/smartgunner_spottingrifle_ammobin_refill
	name = "box of rounded metal plates (SG-153)"
	desc = "A box with round metal plates inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/smartgunner_spottingrifle_ammobin
	refill_amount = 10

/obj/item/factory_refill/auto_sniper_magazine_refill
	name = "box of rounded metal plates (SR-81)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These become produce SR-81 magazines, once finished."
	refill_type = /obj/item/factory_part/auto_sniper_magazine

/obj/item/factory_refill/scout_rifle_magazine_refill
	name = "box of rounded metal plates (BR-8)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become BR-8 magazines, once finished."
	refill_type = /obj/item/factory_part/scout_rifle_magazine
	refill_amount = 20

/obj/item/factory_refill/scout_rifle_incen_magazine_refill
	name = "box of rounded metal plates (BR-8 Inc.)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become BR-8 Incendiary magazines, once finished."
	refill_type = /obj/item/factory_part/scout_rifle_incen_magazine
	refill_amount = 20

/obj/item/factory_refill/scout_rifle_impact_magazine_refill
	name = "box of rounded metal plates (BR-8 Imp.)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become BR-8 Impact magazines, once finished."
	refill_type = /obj/item/factory_part/scout_rifle_impact_magazine
	refill_amount = 20

/obj/item/factory_refill/mateba_speedloader_refill
	name = "box of rounded metal plates (Mateba Speedloader)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Mateba Speedloaders, once finished."
	refill_type = /obj/item/factory_part/mateba_speedloader

/obj/item/factory_refill/railgun_magazine_refill
	name = "box of rounded metal plates (Railgun Mag)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Railgun magazines, once finished."
	refill_type = /obj/item/factory_part/railgun_magazine
	refill_amount = 20

/obj/item/factory_refill/railgun_hvap_magazine_refill
	name = "box of rounded metal plates (Railgun HVAP Mag)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Railgun HVAP magazines, once finished."
	refill_type = /obj/item/factory_part/railgun_hvap_magazine
	refill_amount = 20

/obj/item/factory_refill/railgun_smart_magazine_refill
	name = "box of rounded metal plates (Railgun SMART Mag)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Railgun SMART magazines, once finished."
	refill_type = /obj/item/factory_part/railgun_smart_magazine
	refill_amount = 20

/obj/item/factory_refill/minigun_powerpack_refill
	name = "box of rounded metal plates (Minigun Pack)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Minigun Powerpacks, once finished."
	refill_type = /obj/item/factory_part/minigun_powerpack
	refill_amount = 10

/obj/item/factory_refill/sniper_flak_magazine_refill
	name = "box of rounded metal plates (SR-127 Flak Mag)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become SR-127 Flak magazines, once finished."
	refill_type = /obj/item/factory_part/sniper_flak_magazine
	refill_amount = 20

/obj/item/factory_refill/amr_magazine_refill
	name = "box of rounded metal plates (AMR Mag)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become SR-26 AMR magazines, once finished."
	refill_type = /obj/item/factory_part/amr_magazine
	refill_amount = 20

/obj/item/factory_refill/amr_magazine_incend_refill
	name = "box of rounded metal plates (AMR Inc. Mag)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become SR-26 AMR Incendiary magazines, once finished."
	refill_type = /obj/item/factory_part/amr_magazine_incend
	refill_amount = 20

/obj/item/factory_refill/amr_magazine_flak_refill
	name = "box of rounded metal plates (AMR Flak Mag)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become SR-26 AMR Flak magazines, once finished."
	refill_type = /obj/item/factory_part/amr_magazine_flak
	refill_amount = 20

/obj/item/factory_refill/howitzer_shell_he_refill
	name = "box of rounded metal plates (Howitzer HE)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become High Explosive shells for a Howitzer, once finished."
	refill_type = /obj/item/factory_part/howitzer_shell_he
	refill_amount = 30

/obj/item/factory_refill/howitzer_shell_incen_refill
	name = "box of rounded metal plates (Howitzer Inc.)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Incendiary shells for a howitzer, once finished."
	refill_type = /obj/item/factory_part/howitzer_shell_incen
	refill_amount = 30

/obj/item/factory_refill/howitzer_shell_wp_refill
	name = "box of rounded metal plates (Howitzer WP.)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become White Phosphorous shells for a howitzer, once finished."
	refill_type = /obj/item/factory_part/howitzer_shell_wp
	refill_amount = 30

/obj/item/factory_refill/howitzer_shell_tfoot_refill
	name = "box of rounded metal plates (Howitzer Tanglefoot)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Tanglefoot shells for a howitzer, once finished."
	refill_type = /obj/item/factory_part/howitzer_shell_tfoot
	refill_amount = 30

/obj/item/factory_refill/swat_mask_refill
	name = "box of rounded metal plates (SWAT Mask)"
	desc = "A box of round metal plates inside. Used to refill Unboxers. These will become SWAT masks, once finished."
	refill_type = /obj/item/factory_part/swat_mask
	refill_amount = 20

/obj/item/factory_refill/module_valk_refill
	name = "box of rounded metal plates (Valkyrie)"
	desc = "A box of round metal plates inside. Used to refill Unboxers. These will become Valkyrie autodoc armor modules, once finished."
	refill_type = /obj/item/factory_part/module_valk
	refill_amount = 10

/obj/item/factory_refill/module_mimir2_refill
	name = "box of rounded metal plates (Mimir Mk2)"
	desc = "A box of round metal plates inside. Used to refill Unboxers. These will become Mimir Mark 2 armor and helmet modules, once finished."
	refill_type = /obj/item/factory_part/module_mimir2
	refill_amount = 10

/obj/item/factory_refill/module_tyr2_refill
	name = "box of rounded metal plates (Tyr Mk2)"
	desc = "A box of round metal plates inside. Used to refill Unboxers. These will become Tyr Mark 2 armor modules, once finished."
	refill_type = /obj/item/factory_part/module_tyr2
	refill_amount = 10

/obj/item/factory_refill/module_hlin_refill
	name = "box of rounded metal plates (Hlin)"
	desc = "A box of round metal plates inside. Used to refill Unboxers. These will become Hlin armor modules, once finished."
	refill_type = /obj/item/factory_part/module_hlin
	refill_amount = 10

/obj/item/factory_refill/module_surt_refill
	name = "box of rounded metal plates (Surt)"
	desc = "A box of round metal plates inside. Used to refill Unboxers. These will become Surt armor and helmet modules, once finished."
	refill_type = /obj/item/factory_part/module_surt
	refill_amount = 10

/obj/item/factory_refill/mortar_shell_he_refill
	name = "box of rounded metal plates (Mortar HE)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become High Explosive shells used in mortars, once finished."
	refill_type = /obj/item/factory_part/mortar_shell_he
	refill_amount = 30

/obj/item/factory_refill/mortar_shell_incen_refill
	name = "box of rounded metal plates (Mortar Inc.)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Incendiary shells used in mortars, once finished."
	refill_type = /obj/item/factory_part/mortar_shell_incen
	refill_amount = 30

/obj/item/factory_refill/mortar_shell_tfoot_refill
	name = "box of rounded metal plates (Mortar Tanglefoot)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Tanglefoot smoke shells used in mortars, once finished."
	refill_type = /obj/item/factory_part/mortar_shell_tfoot
	refill_amount = 30

/obj/item/factory_refill/mortar_shell_flare_refill
	name = "box of rounded metal plates (Mortar Flare)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Flare shells used in mortars or howitzers, once finished."
	refill_type = /obj/item/factory_part/mortar_shell_flare
	refill_amount = 30

/obj/item/factory_refill/mortar_shell_smoke_refill
	name = "box of rounded metal plates (Mortar Smoke)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Smoke shells used in mortars, once finished."
	refill_type = /obj/item/factory_part/mortar_shell_flare
	refill_amount = 30

/obj/item/factory_refill/mlrs_rocket_refill
	name = "box of rounded metal plates (MLRS HE Rocket)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become High Explosive rockets for an MLRS, once finished."
	refill_type = /obj/item/factory_part/mlrs_rocket
	refill_amount = 6

/obj/item/factory_refill/mlrs_rocket_refill_gas
	name = "box of rounded metal plates (MLRS X-50 Rocket)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become deadly Gas rockets for an MLRS, once finished."
	refill_type = /obj/item/factory_part/mlrs_rocket/gas
	refill_amount = 6

/obj/item/factory_refill/mlrs_rocket_refill_cloak
	name = "box of rounded metal plates (MLRS Smoke Rocket)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Cloaking Smoke rockets for an MLRS, once finished."
	refill_type = /obj/item/factory_part/mlrs_rocket/cloak
	refill_amount = 6

/obj/item/factory_refill/mlrs_rocket_refill_incendiary
	name = "box of rounded metal plates (MLRS Inc. Rocket)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Incendiary rockets for an MLRS, once finished."
	refill_type = /obj/item/factory_part/mlrs_rocket/incendiary
	refill_amount = 6

/obj/item/factory_refill/agls_he_refill
	name = "box of rounded metal plates (AGLS HE)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become AGLS High Explosive magazines for an AGL, once finished."
	refill_type = /obj/item/factory_part/agls_he
	refill_amount = 10

/obj/item/factory_refill/agls_frag_refill
	name = "box of rounded metal plates (AGLS FRAG)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become AGLS Fragmentation magazines for an AGL, once finished."
	refill_type = /obj/item/factory_part/agls_frag
	refill_amount = 10

/obj/item/factory_refill/agls_incendiary_refill
	name = "box of rounded metal plates (AGLS Inc.)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become AGLS Incendiary magazines for an AGL, once finished."
	refill_type = /obj/item/factory_part/agls_incendiary
	refill_amount = 10

/obj/item/factory_refill/agls_flare_refill
	name = "box of rounded metal plates (AGLS Flare)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become AGLS Flare magazines for an AGL, once finished."
	refill_type = /obj/item/factory_part/agls_flare
	refill_amount = 10

/obj/item/factory_refill/agls_cloak_refill
	name = "box of rounded metal plates (AGLS Smoke)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become AGLS Cloak Smoke magazines for an AGL, once finished."
	refill_type = /obj/item/factory_part/agls_cloak
	refill_amount = 10

/obj/item/factory_refill/atgun_aphe_refill
	name = "box of rounded metal plates (AT APHE)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become AT-36 APHE shells, once finished."
	refill_type = /obj/item/factory_part/atgun_aphe
	refill_amount = 30

/obj/item/factory_refill/atgun_apcr_refill
	name = "box of rounded metal plates (AT APCR)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become AT-36 APCR shells, once finished."
	refill_type = /obj/item/factory_part/atgun_apcr
	refill_amount = 30

/obj/item/factory_refill/atgun_he_refill
	name = "box of rounded metal plates (AT HE)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become AT-36 HE shells, once finished."
	refill_type = /obj/item/factory_part/atgun_he
	refill_amount = 30

/obj/item/factory_refill/atgun_beehive_refill
	name = "box of rounded metal plates (AT Beehive)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become AT-36 Beehive shells, once finished."
	refill_type = /obj/item/factory_part/atgun_beehive
	refill_amount = 30

/obj/item/factory_refill/atgun_incend_refill
	name = "box of rounded metal plates (AT Inc.)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become AT-36 Incendiary shells, once finished."
	refill_type = /obj/item/factory_part/atgun_incend
	refill_amount = 30

/obj/item/factory_refill/heavy_isg_he_refill
	name = "box of rounded metal plates (FK-88 HE)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become FK-88 HE shells, once finished."
	refill_type = /obj/item/factory_part/heavy_isg_he
	refill_amount = 5

/obj/item/factory_refill/heavy_isg_sabot_refill
	name = "box of rounded metal plates (FK-88 APFDS)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become FK-88 APFDS shells, once finished."
	refill_type = /obj/item/factory_part/heavy_isg_sabot
	refill_amount = 5

/obj/item/factory_refill/ac_hv_refill
	name = "box of rounded metal plates (AC HV)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become ATR-22 High Velocity magazines, once finished."
	refill_type = /obj/item/factory_part/ac_hv
	refill_amount = 10

/obj/item/factory_refill/ac_flak_refill
	name = "box of rounded metal plates (AC Flak)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become ATR-22 Flak magazines, once finished."
	refill_type = /obj/item/factory_part/ac_flak
	refill_amount = 10

/obj/item/factory_refill/thermobaric_wp_refill
	name = "box of rounded metal plates (RL-57 Rockets)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become RL-57 White Phosphorous rocket assemblies, once finished."
	refill_type = /obj/item/factory_part/thermobaric_wp
	refill_amount = 15

/obj/item/factory_refill/drop_pod_refill
	name = "box of rounded metal plates (Droppod)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Zeus Orbital Droppods, once finished."
	refill_type = /obj/item/factory_part/drop_pod
	refill_amount = 6

/obj/item/factory_refill/deployable_floodlight_refill
	name = "box of rounded metal plates (Floodlights)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become Portable Floodlights, once finished."
	refill_type = /obj/item/factory_part/deployable_floodlight
	refill_amount = 10

/obj/item/factory_refill/deployable_camera_refill
	name = "box of rounded metal plates (Overwatch)"
	desc = "A box with round metal plates inside. Used to refill Unboxers. These will become deployable overwatch camereas, once finished."
	refill_type = /obj/item/factory_part/deployable_camera
	refill_amount = 30

/obj/item/factory_refill/cigarette_refill
	name = "box of rounded metal plates (Cigarettes)"
	desc = "A box with unfinished cigarettes inside. Used to refill Unboxers."
	refill_type = /obj/item/factory_part/cigarette
	refill_amount = 500
