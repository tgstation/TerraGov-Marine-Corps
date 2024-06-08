//MarineMed vendor

/obj/machinery/vending/MarineMed
	name = "\improper MarineMed"
	desc = "Marine Medical drug dispenser - Provided by Nanotrasen Pharmaceuticals Division(TM)."
	icon_state = "marinemed"
	icon_vend = "marinemed-vend"
	icon_deny = "marinemed-deny"
	product_ads = "Go save some lives!;The best stuff for your medbay.;Only the finest tools.;All natural chemicals!;This stuff saves lives.;Don't you want some?"
	req_one_access = ALL_MARINE_ACCESS
	wrenchable = FALSE
	isshared = TRUE
	products = list(
		"Pill Bottles" = list(
			/obj/item/storage/pill_bottle/bicaridine = -1,
			/obj/item/storage/pill_bottle/kelotane = -1,
			/obj/item/storage/pill_bottle/tramadol = -1,
			/obj/item/storage/pill_bottle/tricordrazine = -1,
			/obj/item/storage/pill_bottle/dylovene = -1,
			/obj/item/storage/pill_bottle/paracetamol = -1,
			/obj/item/storage/pill_bottle/isotonic = -1,
			/obj/item/storage/pill_bottle = -1,
		),
		"Auto Injector" = list(
			/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/kelotane = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tramadol = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/dylovene = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/combat = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/isotonic = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = 30,
			/obj/item/reagent_containers/hypospray/autoinjector/spaceacillin = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/hypervene = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/alkysine = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/imidazoline = 20,
			/obj/item/reagent_containers/hypospray/autoinjector/quickclot = 10,
			/obj/item/reagent_containers/hypospray/autoinjector/medicalnanites = 20,
		),
		"Heal Pack" = list(
			/obj/item/stack/medical/heal_pack/gauze = -1,
			/obj/item/stack/medical/heal_pack/ointment = -1,
			/obj/item/stack/medical/splint = -1,
			/obj/item/stack/medical/heal_pack/advanced/bruise_pack = 50,
			/obj/item/stack/medical/heal_pack/advanced/burn_pack = 50,
		),
		"Misc" = list(
			/obj/item/defibrillator = 8,
			/obj/item/healthanalyzer = 16,
			/obj/item/bodybag/cryobag = 24,
		),
	)

/obj/machinery/vending/MarineMed/valhalla
	resistance_flags = INDESTRUCTIBLE
	use_power = NO_POWER_USE
	products = list(
		"Pill Bottles" = list(
			/obj/item/storage/pill_bottle/bicaridine = -1,
			/obj/item/storage/pill_bottle/kelotane = -1,
			/obj/item/storage/pill_bottle/tramadol = -1,
			/obj/item/storage/pill_bottle/tricordrazine = -1,
			/obj/item/storage/pill_bottle/dylovene = -1,
			/obj/item/storage/pill_bottle/paracetamol = -1,
			/obj/item/storage/pill_bottle/isotonic = -1,
			/obj/item/storage/pill_bottle = -1,
		),
		"Auto Injector" = list(
			/obj/item/reagent_containers/hypospray/autoinjector/bicaridine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/kelotane = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tramadol = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/tricordrazine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/dylovene = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/combat = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/isotonic = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/inaprovaline = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/oxycodone = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/hypervene = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/alkysine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/imidazoline = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/quickclot = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/medicalnanites = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/russian_red = -1,
		),
		"Heal Pack" = list(
			/obj/item/stack/medical/heal_pack/gauze = -1,
			/obj/item/stack/medical/heal_pack/ointment = -1,
			/obj/item/stack/medical/heal_pack/advanced/bruise_pack = -1,
			/obj/item/stack/medical/heal_pack/advanced/burn_pack = -1,
			/obj/item/stack/medical/splint = -1,
		),
		"Misc" = list(
			/obj/item/healthanalyzer = -1,
			/obj/item/healthanalyzer/gloves = -1,
			/obj/item/bodybag/cryobag = -1,
		),
		"Valhalla" = list(
			/obj/item/reagent_containers/hypospray/autoinjector/virilyth = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/roulettium = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/rezadone = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/spaceacillin = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/synaptizine = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/neuraline = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/peridaxon_plus = -1,
			/obj/item/reagent_containers/hypospray/autoinjector/quickclotplus = -1,
		)
	)

//Blood vendor

/obj/machinery/vending/MarineMed/Blood
	name = "\improper MM Blood Dispenser"
	desc = "Marine Med brand Blood Pack dispensery."
	icon_state = "bloodvendor"
	icon_vend = "bloodvendor-vend"
	icon_deny = "bloodvendor-deny"
	product_slogans = "The best blood on the market!;Totally came from an ethical source!;O negative is the universal donor, use it!;Prevent hypovolemic shock starting today!"
	req_one_access = list(ACCESS_MARINE_MEDBAY, ACCESS_MARINE_CHEMISTRY, ACCESS_MARINE_MEDPREP)
	products = list(
		/obj/item/reagent_containers/blood/APlus = 5,
		/obj/item/reagent_containers/blood/AMinus = 5,
		/obj/item/reagent_containers/blood/BPlus = 5,
		/obj/item/reagent_containers/blood/BMinus = 5,
		/obj/item/reagent_containers/blood/OPlus = 5,
		/obj/item/reagent_containers/blood/OMinus = 5,
		/obj/item/reagent_containers/blood/empty = 10,
	)

/obj/machinery/vending/MarineMed/Blood/build_inventory(list/productlist, category)
	. = ..()
	var/temp_list[] = productlist
	var/obj/item/reagent_containers/blood/temp_path
	var/blood_type
	for(var/datum/vending_product/R AS in (product_records + coin_records))
		if(R.product_path in temp_list)
			temp_path = R.product_path
			blood_type = initial(temp_path.blood_type)
			R.product_name += blood_type? " [blood_type]" : ""
			temp_list -= R.product_path
			if(!length(temp_list)) break