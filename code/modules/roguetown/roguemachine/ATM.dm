/obj/structure/roguemachine/atm
	name = "SHYLOCK"
	desc = ""
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "atm"
	density = FALSE
	blade_dulling = DULLING_BASH
	pixel_y = 32

/obj/structure/roguemachine/atm/attack_hand(mob/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.real_name in SStreasury.bank_accounts)
		var/amt = SStreasury.bank_accounts[H.real_name]
		if(!amt)
			say("Your balance is nothing.")
			return
		if(amt < 0)
			say("Your balance is NEGATIVE.")
			return
		var/list/choicez = list()
		if(amt > 10)
			choicez += "GOLD"
		if(amt > 5)
			choicez += "SILVER"
		choicez += "BRONZE"
		var/selection = input(user, "Make a Selection", src) as null|anything in choicez
		if(!selection)
			return
		amt = SStreasury.bank_accounts[H.real_name]
		var/mod = 1
		if(selection == "GOLD")
			mod = 10
		if(selection == "SILVER")
			mod = 5
		var/coin_amt = input(user, "There is [SStreasury.treasury_value] mammon in the treasury. You may withdraw [amt/mod] [selection] COINS from your account.", src) as null|num
		coin_amt = round(coin_amt)
		if(coin_amt < 1)
			return
		amt = SStreasury.bank_accounts[H.real_name]
		if(!Adjacent(user))
			return
		if((coin_amt*mod) > amt)
			playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
			return
		if(!SStreasury.withdraw_money_account(coin_amt*mod, H.real_name))
			playsound(src, 'sound/misc/machineno.ogg', 100, FALSE, -1)
			return
		budget2change(coin_amt*mod, user, selection)
	else
		to_chat(user, "<span class='warning'>The machine bites my finger.</span>")
		icon_state = "atm-b"
		H.flash_fullscreen("redflash3")
		playsound(H, 'sound/combat/hits/bladed/genstab (1).ogg', 100, FALSE, -1)
		SStreasury.create_bank_account(H.real_name)
		spawn(5)
			say("New account created.")
			playsound(src, 'sound/misc/machinetalk.ogg', 100, FALSE, -1)

/*
/obj/structure/roguemachine/atm/attack_right(mob/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
*/

/obj/structure/roguemachine/atm/attackby(obj/item/P, mob/user, params)
	if(ishuman(user))
		if(istype(P, /obj/item/roguecoin))
			var/mob/living/carbon/human/H = user
			if(H.real_name in SStreasury.bank_accounts)
				SStreasury.generate_money_account(P.get_real_price(), H.real_name)
				qdel(P)
				playsound(src, 'sound/misc/coininsert.ogg', 100, FALSE, -1)
				return
			else
				say("No account found. Submit your fingers for inspection.")
	return ..()

