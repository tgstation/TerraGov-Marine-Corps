//MARINE SPECIAL CHEMICALS -APOPHIS - LAST UPDATE - 25JAN2015

//Auto-injectors Items

/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord
	name = "Tricordrazine Auto-Injector"
	desc = "An auto-injector loaded with Tricordrazine."
	amount_per_transfer_from_this = 15
	volume = 15

/obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot
	name = "Quick Clot"
	desc = "An Auto-injector loaded with Quick-clot, a chemical designed to stop internal bleeding instantly."
	amount_per_transfer_from_this = 5
	volume = 5

/obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP
	name = "Dexalin Plus Auto-Injector"
	desc = "A rapid and safe way to administer small amounts of drugs by untrained or trained personnel."
	amount_per_transfer_from_this = 1
	volume = 1

/obj/item/weapon/reagent_containers/hypospray/autoinjector/clonefix
	name = "Clone-Fix"
	desc = "An auto-injector loaded with special chemicals to aid in recovery after cloning, to be used in conjunction with Cryo."
	amount_per_transfer_from_this = 6
	volume = 6

/obj/item/weapon/reagent_containers/hypospray/autoinjector/chloralhydrate
	name = "Anesthetic"
	desc = "An anesthetic autoinjector, to aid with surgery"
	amount_per_transfer_from_this = 10
	volume = 10


//Auto-injector Generation Proc (to change the chemicals)
/obj/item/weapon/reagent_containers/hypospray/autoinjector/tricord/New()
	..()
	spawn(1)
		reagents.add_reagent("tricordrazine", 15)
		update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/quickclot/New()
	..()
	spawn(1)
		reagents.add_reagent("quickclot", 5)
		update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/dexP/New()
	..()
	spawn(1)
		reagents.add_reagent("dexalinp", 1)
		update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/clonefix/New()
	..()
	spawn(1)
		reagents.add_reagent("alkysine", 5)
		reagents.add_reagent("ryetalyn", 1)
		update_icon()
	return

/obj/item/weapon/reagent_containers/hypospray/autoinjector/chloralhydrate/New()
	..()
	spawn(1)
		reagents.add_reagent("chloralhydrate", 1)
		reagents.add_reagent("stoxin", 9)
		update_icon()
	return

