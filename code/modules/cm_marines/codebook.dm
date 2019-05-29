
/obj/item/book/codebook
	name = "Theseus Code Book"
	unique = 1
	dat = ""

/obj/item/book/codebook/New()
	var/letters = list("Alpha","Beta","Gamma","Delta","Epsilon","Zeta","Eta","Theta","Iota","Kappa","Lambda","Mu","Nu","Xi","Omicron","Pi","Rho","Sigma","Tau","Upsilon","Phi","Chi","Psi","Omega")
	var/number
	var/letter
	dat = "<table><tr><th>Call</th><th>Response<th></tr>"
	for(var/i in 1 to 10)
		letter = pick(letters)
		number = rand(100,999)
		dat += "<tr><td>[letter]-[number]</td>"
		letter = pick(letters)
		number = rand(100,999)
		dat += "<td>[letter]-[number]</td></tr>"

	dat += "</table>"

