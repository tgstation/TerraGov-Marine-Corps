/datum/map_template/modular
	name = "Generic modular template"
	mappath = "_maps/modularmaps"
	///ID of this map template
	var/modular_id = "none"
	///Number for its height, used for sanity
	var/template_height = 0
	///Number for its width, used for sanity
	var/template_width = 0
	///Bool for whether we want to to be spawning from the middle or to the topright of the spawner (true is centered)
	var/keepcentered = FALSE
	//minimum player number for a modular map template to be added to the list of potential modular map spawns.
	var/min_player_num
	//maximum player number for a modular map template to be added to the list of potential modular map spawns.
	var/max_player_num

	//FOR MIN AND MAX PLAYER COUNTS TO WORK YOUR MODULAR MAP MUST HAVE BOTH FIELDS, MAPS WITH UNINITIALIZED MIN/MAX VALUES OR WITH JUST ONE OF EITHER VAR WILL ENTER THE MODULAR LIST REGARDLESS OF POP

/datum/map_template/modular/prison
	mappath = "_maps/modularmaps/prison"

/datum/map_template/modular/prison/civresbeach
	name = "Civres South beach"
	mappath = "_maps/modularmaps/prison/civresbeach.dmm"
	modular_id = "southcivres"
	template_width = 9
	template_height = 11

/datum/map_template/modular/prison/civrespool
	name = "Civres south pool"
	mappath = "_maps/modularmaps/prison/civresgym.dmm"
	modular_id = "southcivres"
	template_width = 9
	template_height = 11

/datum/map_template/modular/prison
	mappath = "_maps/modularmaps/lv624"

/datum/map_template/modular/lv624/hydro_path
	name = "Hydro road"
	mappath = "_maps/modularmaps/lv624/hydro_path.dmm"
	modular_id = "hydroroad"
	template_width = 20
	template_height = 20

/datum/map_template/modular/lv624/hydro_jungle
	name = "Hydro maintenance path"
	mappath = "_maps/modularmaps/lv624/hydro_jungle.dmm"
	modular_id = "hydroroad"
	template_width = 20
	template_height = 20

/datum/map_template/modular/lv624/lakebase
	name = "LV lake"
	mappath = "_maps/modularmaps/lv624/lakebase.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33
	min_player_num = 60
	max_player_num = INFINITY

/datum/map_template/modular/lv624/cavemapone
	name = "LV cavern one"
	mappath = "_maps/modularmaps/lv624/newcavevar1.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33

/datum/map_template/modular/lv624/cavemaptwo
	name = "LV cavern two"
	mappath = "_maps/modularmaps/lv624/newcavevar2.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33

/datum/map_template/modular/lv624/cavemapthree
	name = "LV cavern three"
	mappath = "_maps/modularmaps/lv624/newcavevar3.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33
	min_player_num = 0
	max_player_num = 45

/datum/map_template/modular/lv624/cavemapfour
	name = "LV cavern four"
	mappath = "_maps/modularmaps/lv624/newcavevar4.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33

/datum/map_template/modular/lv624/cavemapfive
	name = "LV cavern five"
	mappath = "_maps/modularmaps/lv624/newcavevar5.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33

/datum/map_template/modular/lv624/cavemapsix
	name = "LV cavern six"
	mappath = "_maps/modularmaps/lv624/newcavevar6.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33

/datum/map_template/modular/lv624/cavemapseven
	name = "LV cavern seven"
	mappath = "_maps/modularmaps/lv624/newcavevar7.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33

/datum/map_template/modular/lv624/cavemapeight
	name = "LV cavern eight"
	mappath = "_maps/modularmaps/lv624/newcavevar8.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33

/datum/map_template/modular/lv624/cavemapnine
	name = "LV cavern nine"
	mappath = "_maps/modularmaps/lv624/newcavevar9.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33

/datum/map_template/modular/lv624/cavemapten
	name = "LV cavern ten"
	mappath = "_maps/modularmaps/lv624/newcavevar10.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33

/datum/map_template/modular/lv624/cavemapeleven
	name = "LV cavern eleven"
	mappath = "_maps/modularmaps/lv624/newcavevar11.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33

/datum/map_template/modular/lv624/cavemaptwelve
	mappath = "_maps/modularmaps/lv624/newcavevar12.dmm"
	modular_id = "lvcaveslakearea"
	template_width = 80
	template_height = 33
	min_player_num = 65
	max_player_num = INFINITY

/datum/map_template/modular/lv624/medicaldomeone
	name = "Medical dome one"
	mappath = "_maps/modularmaps/lv624/medbayone.dmm"
	modular_id = "lvmedicaldome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/medicaldometwo
	name = "Medical dome two"
	mappath = "_maps/modularmaps/lv624/medbaytwo.dmm"
	modular_id = "lvmedicaldome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/lvhydrobridgeone
	name = "LV Hydro Bridge One"
	mappath = "_maps/modularmaps/lv624/lvhydrobridge1.dmm"
	modular_id = "lvhydrobridge"
	template_width = 8
	template_height = 10

/datum/map_template/modular/lv624/lvhydrobridgetwo
	name = "LV Hydro Bridge Two"
	mappath = "_maps/modularmaps/lv624/lvhydrobridge2.dmm"
	modular_id = "lvhydrobridge"
	template_width = 8
	template_height = 10

/datum/map_template/modular/lv624/lvhydrobridgethree
	name = "LV Hydro Bridge Three"
	mappath = "_maps/modularmaps/lv624/lvhydrobridge3.dmm"
	modular_id = "lvhydrobridge"
	template_width = 8
	template_height = 10

/datum/map_template/modular/lv624/lvhydrobridgefour
	name = "LV Hydro Bridge Four"
	mappath = "_maps/modularmaps/lv624/lvhydrobridge4.dmm"
	modular_id = "lvhydrobridge"
	template_width = 8
	template_height = 10

/datum/map_template/modular/lv624/southsandtempleone
	name = "LV South Sand Temple One"
	mappath = "_maps/modularmaps/lv624/southsandtemple1.dmm"
	modular_id = "lvsouthsandtemple"
	template_width = 22
	template_height = 24

/datum/map_template/modular/lv624/southsandtempletwo
	name = "LV South Sand Temple Two"
	mappath = "_maps/modularmaps/lv624/southsandtemple2.dmm"
	modular_id = "lvsouthsandtemple"
	template_width = 22
	template_height = 24

/datum/map_template/modular/lv624/southsandtemplethree
	name = "LV South Sand Temple Three"
	mappath = "_maps/modularmaps/lv624/southsandtemple3.dmm"
	modular_id = "lvsouthsandtemple"
	template_width = 22
	template_height = 24

/datum/map_template/modular/lv624/southsandtemplefour
	name = "LV South Sand Temple Four"
	mappath = "_maps/modularmaps/lv624/southsandtemple4.dmm"
	modular_id = "lvsouthsandtemple"
	template_width = 22
	template_height = 24

/datum/map_template/modular/lv624/dome_atmos
	name = "LV atmos dome"
	mappath = "_maps/modularmaps/lv624/atmospherics.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/dome_robotics
	name = "LV robotics dome"
	mappath = "_maps/modularmaps/lv624/robotics.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/dome_telecomms
	name = "LV telecomms dome"
	mappath = "_maps/modularmaps/lv624/telecomms.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/dome_cargo_bay
	name = "LV cargo dome"
	mappath = "_maps/modularmaps/lv624/cargo_bay.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/dome_cargo_bay_two
	name = "LV cargo dome"
	mappath = "_maps/modularmaps/lv624/cargo_bay2.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/dome_internal_affairs
	name = "LV internal affairs dome"
	mappath = "_maps/modularmaps/lv624/internal_affairs.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/lv624/dome_internal_affairs
	name = "LV auxillary botany dome"
	mappath = "_maps/modularmaps/lv624/auxbotany.dmm"
	modular_id = "lvdome"
	template_width = 15
	template_height = 15
	keepcentered = TRUE

/datum/map_template/modular/bigred/eastone
	name = "Big red east caves"
	mappath = "_maps/modularmaps/big_red/bigredcavevar1.dmm"
	modular_id = "breastcaves"
	template_width = 66
	template_height = 42

/datum/map_template/modular/bigred/easttwo
	name = "Big red east caves"
	mappath = "_maps/modularmaps/big_red/bigredcavevar2.dmm"
	modular_id = "breastcaves"
	template_width = 66
	template_height = 42

/datum/map_template/modular/bigred/eastthree
	name = "Big red east caves"
	mappath = "_maps/modularmaps/big_red/bigredcavevar3.dmm"
	modular_id = "breastcaves"
	template_width = 66
	template_height = 42

/datum/map_template/modular/bigred/eastfour
	name = "Big red east caves"
	mappath = "_maps/modularmaps/big_red/bigredcavevar4.dmm"
	modular_id = "breastcaves"
	template_width = 66
	template_height = 42

/datum/map_template/modular/bigred/eastfive
	name = "Big red east caves"
	mappath = "_maps/modularmaps/big_red/bigredcavevar5.dmm"
	modular_id = "breastcaves"
	template_width = 66
	template_height = 42

/datum/map_template/modular/bigred/cargoentryone
	name = "Big red cargo entry"
	mappath = "_maps/modularmaps/big_red/bigredcargoentryvar1.dmm"
	modular_id = "brcargoentry"
	template_width = 3
	template_height = 5

/datum/map_template/modular/bigred/cargoentrytwo
	name = "Big red cargo area"
	mappath = "_maps/modularmaps/big_red/bigredcargoentryvar2.dmm"
	modular_id = "brcargoentry"
	template_width = 3
	template_height = 5

/datum/map_template/modular/bigred/cargoentrythree
	name = "Big red cargo area"
	mappath = "_maps/modularmaps/big_red/bigredcargoentryvar3.dmm"
	modular_id = "brcargoentry"
	template_width = 3
	template_height = 5

/datum/map_template/modular/bigred/cargoareaone
	name = "Big red cargo area"
	mappath = "_maps/modularmaps/big_red/bigredcargoareavar1.dmm"
	modular_id = "brcargoarea"
	template_width = 54
	template_height = 22

/datum/map_template/modular/bigred/cargoareatwo
	name = "Big red cargo area"
	mappath = "_maps/modularmaps/big_red/bigredcargoareavar2.dmm"
	modular_id = "brcargoarea"
	template_width = 54
	template_height = 22

/datum/map_template/modular/bigred/cargoareathree
	name = "Big red cargo area"
	mappath = "_maps/modularmaps/big_red/bigredcargoareavar3.dmm"
	modular_id = "brcargoarea"
	template_width = 54
	template_height = 22

/datum/map_template/modular/bigred/cargoareafour
	name = "Big red cargo area"
	mappath = "_maps/modularmaps/big_red/bigredcargoareavar4.dmm"
	modular_id = "brcargoarea"
	template_width = 54
	template_height = 22


/datum/map_template/modular/bigred/cargoareafive
	name = "Big red cargo area"
	mappath = "_maps/modularmaps/big_red/bigredcargoareavar5.dmm"
	modular_id = "brcargoarea"
	template_width = 54
	template_height = 22

/datum/map_template/modular/bigred/cargoareasix
	name = "Big red cargo area"
	mappath = "_maps/modularmaps/big_red/bigredcargoareavar6.dmm"
	modular_id = "brcargoarea"
	template_width = 54
	template_height = 22

/datum/map_template/modular/bigred/cargoareaseven
	name = "Big red cargo area"
	mappath = "_maps/modularmaps/big_red/bigredcargoareavar7.dmm"
	modular_id = "brcargoarea"
	template_width = 54
	template_height = 22

/datum/map_template/modular/bigred/cargoareaeight
	name = "Big red cargo area"
	mappath = "_maps/modularmaps/big_red/bigredcargoareavar8.dmm"
	modular_id = "brcargoarea"
	template_width = 54
	template_height = 22

/datum/map_template/modular/bigred/chapelone
	name = "Big red chapel"
	mappath = "_maps/modularmaps/big_red/bigredchapelvar1.dmm"
	modular_id = "brchapel"
	template_width = 18
	template_height = 9

/datum/map_template/modular/bigred/chapeltwo
	name = "Big red chapel"
	mappath = "_maps/modularmaps/big_red/bigredchapelvar2.dmm"
	modular_id = "brchapel"
	template_width = 18
	template_height = 9

/datum/map_template/modular/bigred/medbayone
	name = "Big red medbay"
	mappath = "_maps/modularmaps/big_red/bigredmedbayvar1.dmm"
	modular_id = "brmedbay"
	template_width = 33
	template_height = 26

/datum/map_template/modular/bigred/medbaytwo
	name = "Big red medbay"
	mappath = "_maps/modularmaps/big_red/bigredmedbayvar2.dmm"
	modular_id = "brmedbay"
	template_width = 33
	template_height = 26

/datum/map_template/modular/bigred/medbaythree
	name = "Big red medbay"
	mappath = "_maps/modularmaps/big_red/bigredmedbayvar3.dmm"
	modular_id = "brmedbay"
	template_width = 33
	template_height = 26

/datum/map_template/modular/bigred/medbayfour
	name = "Big red medbay"
	mappath = "_maps/modularmaps/big_red/bigredmedbayvar4.dmm"
	modular_id = "brmedbay"
	template_width = 33
	template_height = 26

/datum/map_template/modular/bigred/medbayfive
	name = "Big red medbay"
	mappath = "_maps/modularmaps/big_red/bigredmedbayvar5.dmm"
	modular_id = "brmedbay"
	template_width = 33
	template_height = 26

/datum/map_template/modular/bigred/medbaysix
	name = "Big red medbay"
	mappath = "_maps/modularmaps/big_red/bigredmedbayvar6.dmm"
	modular_id = "brmedbay"
	template_width = 33
	template_height = 26

/datum/map_template/modular/bigred/medbayseven
	name = "Big red medbay"
	mappath = "_maps/modularmaps/big_red/bigredmedbayvar7.dmm"
	modular_id = "brmedbay"
	template_width = 33
	template_height = 26

/datum/map_template/modular/bigred/officeone
	name = "Big red office"
	mappath = "_maps/modularmaps/big_red/bigredofficevar1.dmm"
	modular_id = "broffice"
	template_width = 28
	template_height = 23

/datum/map_template/modular/bigred/officetwo
	name = "Big red office"
	mappath = "_maps/modularmaps/big_red/bigredofficevar2.dmm"
	modular_id = "broffice"
	template_width = 28
	template_height = 23

/datum/map_template/modular/bigred/officethree
	name = "Big red office"
	mappath = "_maps/modularmaps/big_red/bigredofficevar3.dmm"
	modular_id = "broffice"
	template_width = 28
	template_height = 23

/datum/map_template/modular/bigred/officefour
	name = "Big red office"
	mappath = "_maps/modularmaps/big_red/bigredofficevar4.dmm"
	modular_id = "broffice"
	template_width = 28
	template_height = 23

/datum/map_template/modular/bigred/atmosone
	name = "Big red atmos"
	mappath = "_maps/modularmaps/big_red/bigredatmosvar1.dmm"
	modular_id = "bratmos"
	template_width = 24
	template_height = 25

/datum/map_template/modular/bigred/atmostwo
	name = "Big red atmos"
	mappath = "_maps/modularmaps/big_red/bigredatmosvar2.dmm"
	modular_id = "bratmos"
	template_width = 24
	template_height = 25

/datum/map_template/modular/bigred/atmosthree
	name = "Big red atmos"
	mappath = "_maps/modularmaps/big_red/bigredatmosvar3.dmm"
	modular_id = "bratmos"
	template_width = 24
	template_height = 25

/datum/map_template/modular/bigred/atmosfour
	name = "Big red atmos"
	mappath = "_maps/modularmaps/big_red/bigredatmosvar4.dmm"
	modular_id = "bratmos"
	template_width = 24
	template_height = 25

/datum/map_template/modular/bigred/atmosfive
	name = "Big red atmos"
	mappath = "_maps/modularmaps/big_red/bigredatmosvar5.dmm"
	modular_id = "bratmos"
	template_width = 24
	template_height = 25

/datum/map_template/modular/bigred/atmossix
	name = "Big red atmos"
	mappath = "_maps/modularmaps/big_red/bigredatmosvar6.dmm"
	modular_id = "bratmos"
	template_width = 24
	template_height = 25

/datum/map_template/modular/bigred/cargoone
	name = "Big red cargo"
	mappath = "_maps/modularmaps/big_red/bigredcargovar1.dmm"
	modular_id = "brcargo"
	template_width = 19
	template_height = 19

/datum/map_template/modular/bigred/cargotwo
	name = "Big red cargo"
	mappath = "_maps/modularmaps/big_red/bigredcargovar2.dmm"
	modular_id = "brcargo"
	template_width = 19
	template_height = 19

/datum/map_template/modular/bigred/engione
	name = "Big red engineering"
	mappath = "_maps/modularmaps/big_red/bigredengineeringvar1.dmm"
	modular_id = "brengineering"
	template_width = 30
	template_height = 27

/datum/map_template/modular/bigred/engitwo
	name = "Big red engineering"
	mappath = "_maps/modularmaps/big_red/bigredengineeringvar2.dmm"
	modular_id = "brengineering"
	template_width = 30
	template_height = 27

/datum/map_template/modular/bigred/engithree
	name = "Big red engineering"
	mappath = "_maps/modularmaps/big_red/bigredengineeringvar3.dmm"
	modular_id = "brengineering"
	template_width = 30
	template_height = 27

/datum/map_template/modular/bigred/engifour
	name = "Big red engineering"
	mappath = "_maps/modularmaps/big_red/bigredengineeringvar4.dmm"
	modular_id = "brengineering"
	template_width = 30
	template_height = 27

/datum/map_template/modular/bigred/etaone
	name = "Big red eta"
	mappath = "_maps/modularmaps/big_red/bigredetavar1.dmm"
	modular_id = "breta"
	template_width = 26
	template_height = 24

/datum/map_template/modular/bigred/etatwo
	name = "Big red eta"
	mappath = "_maps/modularmaps/big_red/bigredetavar2.dmm"
	modular_id = "breta"
	template_width = 26
	template_height = 24

/datum/map_template/modular/bigred/etathree
	name = "Big red eta"
	mappath = "_maps/modularmaps/big_red/bigredetavar3.dmm"
	modular_id = "breta"
	template_width = 26
	template_height = 24

/datum/map_template/modular/bigred/etafour
	name = "Big red eta"
	mappath = "_maps/modularmaps/big_red/bigredetavar4.dmm"
	modular_id = "breta"
	template_width = 26
	template_height = 24

/datum/map_template/modular/bigred/etafive
	name = "Big red eta"
	mappath = "_maps/modularmaps/big_red/bigredetavar5.dmm"
	modular_id = "breta"
	template_width = 26
	template_height = 24

/datum/map_template/modular/bigred/medbaypassageone
	name = "Big red medbaypassage"
	mappath = "_maps/modularmaps/big_red/bigredmedbaypassagevar1.dmm"
	modular_id = "brmedbaypassage"
	template_width = 6
	template_height = 3

/datum/map_template/modular/bigred/medbaypassagetwo
	name = "Big red medbaypassage"
	mappath = "_maps/modularmaps/big_red/bigredmedbaypassagevar2.dmm"
	modular_id = "brmedbaypassage"
	template_width = 6
	template_height = 3

/datum/map_template/modular/bigred/dormsone
	name = "Big red dorms"
	mappath = "_maps/modularmaps/big_red/bigreddormvar1.dmm"
	modular_id = "brdorms"
	template_width = 19
	template_height = 7

/datum/map_template/modular/bigred/dormstwo
	name = "Big red dorms"
	mappath = "_maps/modularmaps/big_red/bigreddormvar2.dmm"
	modular_id = "brdorms"
	template_width = 19
	template_height = 7

/datum/map_template/modular/bigred/lambdatunnelnorthone
	name = "Big red lambda caves"
	mappath = "_maps/modularmaps/big_red/bigrednorthlambdavar1.dmm"
	modular_id = "brlambdatunnelnorth"
	template_width = 65
	template_height = 32

/datum/map_template/modular/bigred/lambdatunnelnorthtwo
	name = "Big red lambda caves"
	mappath = "_maps/modularmaps/big_red/bigrednorthlambdavar2.dmm"
	modular_id = "brlambdatunnelnorth"
	template_width = 65
	template_height = 32

/datum/map_template/modular/bigred/lambdatunnelnorththree
	name = "Big red lambda caves"
	mappath = "_maps/modularmaps/big_red/bigrednorthlambdavar3.dmm"
	modular_id = "brlambdatunnelnorth"
	template_width = 65
	template_height = 32

/datum/map_template/modular/bigred/lambdatunnelnorthfour
	name = "Big red lambda caves"
	mappath = "_maps/modularmaps/big_red/bigrednorthlambdavar4.dmm"
	modular_id = "brlambdatunnelnorth"
	template_width = 65
	template_height = 32

/datum/map_template/modular/bigred/lambdatunnelnorthfive
	name = "Big red lambda caves"
	mappath = "_maps/modularmaps/big_red/bigrednorthlambdavar5.dmm"
	modular_id = "brlambdatunnelnorth"
	template_width = 65
	template_height = 32

/datum/map_template/modular/bigred/lambdatunnelnorthsix
	name = "Big red lambda caves"
	mappath = "_maps/modularmaps/big_red/bigrednorthlambdavar6.dmm"
	modular_id = "brlambdatunnelnorth"
	template_width = 65
	template_height = 32

/datum/map_template/modular/bigred/lambdatunneltwo
	name = "Big red lambda caves"
	mappath = "_maps/modularmaps/big_red/bigredlambdatunnelvar2.dmm"
	modular_id = "brlambdatunnel"
	template_width = 25
	template_height = 6

/datum/map_template/modular/bigred/lambdacavesone
	name = "Big red lambda tunnel"
	mappath = "_maps/modularmaps/big_red/bigredlambdacave1.dmm"
	modular_id = "brlambdacave"
	template_width = 15
	template_height = 15

/datum/map_template/modular/bigred/lambdatunnelsouthone
	name = "Big red lambda tunnel"
	mappath = "_maps/modularmaps/big_red/bigredlambdatunnelsouthvar1.dmm"
	modular_id = "brlambdatunnelsouth"
	template_width = 22
	template_height = 11

/datum/map_template/modular/bigred/lambdatunnelsouthtwo
	name = "Big red lambda tunnel"
	mappath = "_maps/modularmaps/big_red/bigredlambdatunnelsouthvar2.dmm"
	modular_id = "brlambdatunnelsouth"
	template_width = 22
	template_height = 11

/datum/map_template/modular/bigred/lambdatunnelsouththree
	name = "Big red lambda tunnel"
	mappath = "_maps/modularmaps/big_red/bigredlambdatunnelsouthvar3.dmm"
	modular_id = "brlambdatunnelsouth"
	template_width = 22
	template_height = 11

/datum/map_template/modular/bigred/lambdatunnelsouthfour
	name = "Big red lambda tunnel"
	mappath = "_maps/modularmaps/big_red/bigredlambdatunnelsouthvar4.dmm"
	modular_id = "brlambdatunnelsouth"
	template_width = 22
	template_height = 11

/datum/map_template/modular/bigred/checkpointsouthone
	name = "Big red checkpoint south"
	mappath = "_maps/modularmaps/big_red/bigredcheckpointsouthvar1.dmm"
	modular_id = "brcheckpointsouth"
	template_width = 12
	template_height = 10

/datum/map_template/modular/bigred/checkpointsouthtwo
	name = "Big red checkpoint south"
	mappath = "_maps/modularmaps/big_red/bigredcheckpointsouthvar2.dmm"
	modular_id = "brcheckpointsouth"
	template_width = 12
	template_height = 10

/datum/map_template/modular/bigred/checkpointsouththree
	name = "Big red checkpoint south"
	mappath = "_maps/modularmaps/big_red/bigredcheckpointsouthvar3.dmm"
	modular_id = "brcheckpointsouth"
	template_width = 12
	template_height = 10

/datum/map_template/modular/bigred/westetaone
	name = "Big red southwest eta"
	mappath = "_maps/modularmaps/big_red/bigredsouthwestetavar1.dmm"
	modular_id = "brsouthwesteta"
	template_width = 61
	template_height = 38

/datum/map_template/modular/bigred/westetatwo
	name = "Big red southwest eta"
	mappath = "_maps/modularmaps/big_red/bigredsouthwestetavar2.dmm"
	modular_id = "brsouthwesteta"
	template_width = 61
	template_height = 38

/datum/map_template/modular/bigred/westetathree
	name = "Big red southwest eta"
	mappath = "_maps/modularmaps/big_red/bigredsouthwestetavar3.dmm"
	modular_id = "brsouthwesteta"
	template_width = 61
	template_height = 38

/datum/map_template/modular/bigred/westetafour
	name = "Big red southwest eta"
	mappath = "_maps/modularmaps/big_red/bigredsouthwestetavar4.dmm"
	modular_id = "brsouthwesteta"
	template_width = 61
	template_height = 38

/datum/map_template/modular/bigred/westetafive
	name = "Big red southwest eta"
	mappath = "_maps/modularmaps/big_red/bigredsouthwestetavar5.dmm"
	modular_id = "brsouthwesteta"
	template_width = 61
	template_height = 38

/datum/map_template/modular/bigred/southetaone
	name = "Big red southwest eta"
	mappath = "_maps/modularmaps/big_red/bigredsouthetavar1.dmm"
	modular_id = "brsoutheta"
	template_width = 23
	template_height = 10

/datum/map_template/modular/bigred/southetatwo
	name = "Big red southwest eta"
	mappath = "_maps/modularmaps/big_red/bigredsouthetavar2.dmm"
	modular_id = "brsoutheta"
	template_width = 23
	template_height = 10

/datum/map_template/modular/bigred/southetathree
	name = "Big red southwest eta"
	mappath = "_maps/modularmaps/big_red/bigredsouthetavar3.dmm"
	modular_id = "brsoutheta"
	template_width = 23
	template_height = 10

/datum/map_template/modular/bigred/southetafour
	name = "Big red southwest eta"
	mappath = "_maps/modularmaps/big_red/bigredsouthetavar4.dmm"
	modular_id = "brsoutheta"
	template_width = 23
	template_height = 10

/datum/map_template/modular/bigred/southetafive
	name = "Big red southwest eta"
	mappath = "_maps/modularmaps/big_red/bigredsouthetavar5.dmm"
	modular_id = "brsoutheta"
	template_width = 23
	template_height = 10

/datum/map_template/modular/bigred/checkpointone
	name = "Big red checkpoint"
	mappath = "_maps/modularmaps/big_red/bigredcheckpointvar1.dmm"
	modular_id = "brcheckpoint"
	template_width = 4
	template_height = 4

/datum/map_template/modular/bigred/checkpointtwo
	name = "Big red checkpoint"
	mappath = "_maps/modularmaps/big_red/bigredcheckpointvar2.dmm"
	modular_id = "brcheckpoint"
	template_width = 4
	template_height = 4

/datum/map_template/modular/bigred/libraryone
	name = "Big red library"
	mappath = "_maps/modularmaps/big_red/bigredlibraryvar1.dmm"
	modular_id = "brlibrary"
	template_width = 11
	template_height = 18

/datum/map_template/modular/bigred/librarytwo
	name = "Big red library"
	mappath = "_maps/modularmaps/big_red/bigredlibraryvar2.dmm"
	modular_id = "brlibrary"
	template_width = 11
	template_height = 18

/datum/map_template/modular/bigred/librarythree
	name = "Big red library"
	mappath = "_maps/modularmaps/big_red/bigredlibraryvar3.dmm"
	modular_id = "brlibrary"
	template_width = 11
	template_height = 18

/datum/map_template/modular/bigred/lambdatunnelsouththree
	name = "Big red lambda tunnel"
	mappath = "_maps/modularmaps/big_red/bigredlambdatunnelsouthvar3.dmm"
	modular_id = "brlambdatunnelsouth"
	template_width = 22
	template_height = 11

/datum/map_template/modular/bigred/lambdatunnelone
	name = "Big red lambda tunnel"
	mappath = "_maps/modularmaps/big_red/bigredlambdatunnelvar1.dmm"
	modular_id = "brlambdatunnel"
	template_width = 25
	template_height = 6

/datum/map_template/modular/bigred/lambdacavestwo
	name = "Big red dorms"
	mappath = "_maps/modularmaps/big_red/bigredlambdacave2.dmm"
	modular_id = "brlambdacave"
	template_width = 15
	template_height = 15

/datum/map_template/modular/bigred/secornerone
	name = "Big red southeastern caves"
	mappath = "_maps/modularmaps/big_red/bigredsecornervar1.dmm"
	modular_id = "brsecorner"
	template_width = 71
	template_height = 67

/datum/map_template/modular/bigred/secornertwo
	name = "Big red southeastern caves"
	mappath = "_maps/modularmaps/big_red/bigredsecornervar2.dmm"
	modular_id = "brsecorner"
	template_width = 71
	template_height = 67

/datum/map_template/modular/bigred/secornerthree
	name = "Big red southeastern caves"
	mappath = "_maps/modularmaps/big_red/bigredsecornervar3.dmm"
	modular_id = "brsecorner"
	template_width = 71
	template_height = 67

/datum/map_template/modular/bigred/secornerfour
	name = "Big red southeastern caves"
	mappath = "_maps/modularmaps/big_red/bigredsecornervar4.dmm"
	modular_id = "brsecorner"
	template_width = 71
	template_height = 67

/datum/map_template/modular/bigred/secornerfive
	name = "Big red southeastern caves"
	mappath = "_maps/modularmaps/big_red/bigredsecornervar5.dmm"
	modular_id = "brsecorner"
	template_width = 71
	template_height = 67

/datum/map_template/modular/bigred/secornersix
	name = "Big red southeastern caves"
	mappath = "_maps/modularmaps/big_red/bigredsecornervar6.dmm"
	modular_id = "brsecorner"
	template_width = 71
	template_height = 67

/datum/map_template/modular/bigred/secornerseven
	name = "Big red southeastern caves"
	mappath = "_maps/modularmaps/big_red/bigredsecornervar7.dmm"
	modular_id = "brsecorner"
	template_width = 71
	template_height = 67

/datum/map_template/modular/bigred/toolshedone
	name = "Big red tool shed"
	mappath = "_maps/modularmaps/big_red/bigredtoolshedvar1.dmm"
	modular_id = "brtoolshed"
	template_width = 16
	template_height = 9

/datum/map_template/modular/bigred/toolshedtwo
	name = "Big red tool shed"
	mappath = "_maps/modularmaps/big_red/bigredtoolshedvar2.dmm"
	modular_id = "brtoolshed"
	template_width = 16
	template_height = 9

/datum/map_template/modular/bigred/toolshedthree
	name = "Big red tool shed"
	mappath = "_maps/modularmaps/big_red/bigredtoolshedvar3.dmm"
	modular_id = "brtoolshed"
	template_width = 16
	template_height = 9

/datum/map_template/modular/bigred/toolshedfour
	name = "Big red tool shed"
	mappath = "_maps/modularmaps/big_red/bigredtoolshedvar4.dmm"
	modular_id = "brtoolshed"
	template_width = 16
	template_height = 9


/datum/map_template/modular/bigred/toolshedfive
	name = "Big red tool shed"
	mappath = "_maps/modularmaps/big_red/bigredtoolshedvar5.dmm"
	modular_id = "brtoolshed"
	template_width = 16
	template_height = 9

/datum/map_template/modular/bigred/southwestcornerone
	name = "Big red southwestern corner"
	mappath = "_maps/modularmaps/big_red/bigredcaveswvar1.dmm"
	modular_id = "brswcorner"
	template_width = 41
	template_height = 43

/datum/map_template/modular/bigred/southwestcornertwo
	name = "Big red southwestern corner"
	mappath = "_maps/modularmaps/big_red/bigredcaveswvar2.dmm"
	modular_id = "brswcorner"
	template_width = 41
	template_height = 43

/datum/map_template/modular/bigred/southwestcornerthree
	name = "Big red southwestern corner"
	mappath = "_maps/modularmaps/big_red/bigredcaveswvar3.dmm"
	modular_id = "brswcorner"
	template_width = 41
	template_height = 43

/datum/map_template/modular/bigred/southwestcornerfour
	name = "Big red southwestern corner"
	mappath = "_maps/modularmaps/big_red/bigredcaveswvar4.dmm"
	modular_id = "brswcorner"
	template_width = 41
	template_height = 43

/datum/map_template/modular/bigred/southwestcornerfive
	name = "Big red southwestern corner"
	mappath = "_maps/modularmaps/big_red/bigredcaveswvar5.dmm"
	modular_id = "brswcorner"
	template_width = 41
	template_height = 43

/datum/map_template/modular/bigred/lambdalockone
	name = "Big red lockdown shutters"
	mappath = "_maps/modularmaps/big_red/bigreddoor1.dmm"
	modular_id = "brlambdalock"
	template_width = 1
	template_height = 2
	min_player_num = 45
	max_player_num = INFINITY

/datum/map_template/modular/bigred/lambdalocktwo
	name = "Big red lockdown shutters"
	mappath = "_maps/modularmaps/big_red/bigreddoor2.dmm"
	modular_id = "brlambdalock"
	template_width = 1
	template_height = 2

/datum/map_template/modular/bigred/lambdalockthree
	name = "Big red lockdown shutters"
	mappath = "_maps/modularmaps/big_red/bigreddoor3.dmm"
	modular_id = "brlambdalock"
	template_width = 1
	template_height = 2
	min_player_num = 45
	max_player_num = INFINITY

/datum/map_template/modular/bigred/lambdalockfour
	name = "Big red lockdown shutters"
	mappath = "_maps/modularmaps/big_red/bigreddoor4.dmm"
	modular_id = "brlambdalock"
	template_width = 1
	template_height = 2

/datum/map_template/modular/bigred/generalstoreone
	name = "Big red general store"
	mappath = "_maps/modularmaps/big_red/bigredgeneralstorevar1.dmm"
	modular_id = "brgeneral"
	template_width = 31
	template_height = 14

/datum/map_template/modular/bigred/generalstoretwo
	name = "Big red general store"
	mappath = "_maps/modularmaps/big_red/bigredgeneralstorevar2.dmm"
	modular_id = "brgeneral"
	template_width = 31
	template_height = 14

/datum/map_template/modular/bigred/sweastone
	name = "Big red general store"
	mappath = "_maps/modularmaps/big_red/bigredsweastcornervar1.dmm"
	modular_id = "brsweast"
	template_width = 44
	template_height = 22

/datum/map_template/modular/bigred/sweasttwo
	name = "Big red general store"
	mappath = "_maps/modularmaps/big_red/bigredsweastcornervar2.dmm"
	modular_id = "brsweast"
	template_width = 44
	template_height = 22

/datum/map_template/modular/bigred/sweastthree
	name = "Big red general store"
	mappath = "_maps/modularmaps/big_red/bigredsweastcornervar3.dmm"
	modular_id = "brsweast"
	template_width = 44
	template_height = 22

/datum/map_template/modular/bigred/sweastfour
	name = "Big red general store"
	mappath = "_maps/modularmaps/big_red/bigredsweastcornervar4.dmm"
	modular_id = "brsweast"
	template_width = 44
	template_height = 22

/datum/map_template/modular/bigred/sweastfive
	name = "Big red general store"
	mappath = "_maps/modularmaps/big_red/bigredsweastcornervar5.dmm"
	modular_id = "brsweast"
	template_width = 44
	template_height = 22

/datum/map_template/modular/bigred/barracks
	name = "Big red Barracks"
	mappath = "_maps/modularmaps/big_red/barracks.dmm"
	modular_id = "broperations"
	template_width = 29
	template_height = 24

/datum/map_template/modular/bigred/operations
	name = "Big red administration"
	mappath = "_maps/modularmaps/big_red/operation.dmm"
	modular_id = "broperations"
	template_width = 29
	template_height = 24

/datum/map_template/modular/oscaroutposttopone
	name = "Oscar outpost map top half"
	mappath = "_maps/modularmaps/oscaroutpost/oscarnorthvar1.dmm"
	modular_id = "oscartop"
	template_width = 150
	template_height = 153

/datum/map_template/modular/oscaroutposttoptwo
	name = "Oscar outpost map top half"
	mappath = "_maps/modularmaps/oscaroutpost/oscarnorthvar2.dmm"
	modular_id = "oscartop"
	template_width = 150
	template_height = 153

/datum/map_template/modular/oscaroutposttopthree
	mappath = "_maps/modularmaps/oscaroutpost/oscarnorthvar3.dmm"
	modular_id = "oscartop"
	template_width = 150
	template_height = 153

/datum/map_template/modular/oscaroutposttopfour
	mappath = "_maps/modularmaps/oscaroutpost/oscarnorthvar4.dmm"
	modular_id = "oscartop"
	template_width = 150
	template_height = 153

/datum/map_template/modular/oscaroutzetabaseone
	name = "Oscar outpost abandoned base"
	mappath = "_maps/modularmaps/oscaroutpost/oscarsouthvar1.dmm"
	modular_id = "oscarbase"
	template_width = 79
	template_height = 29

/datum/map_template/modular/oscaroutzetabasetwo
	name = "Oscar outpost abandoned base"
	mappath = "_maps/modularmaps/oscaroutpost/oscarsouthvar2.dmm"
	modular_id = "oscarbase"
	template_width = 79
	template_height = 29

/datum/map_template/modular/oscaroutzetabasethree
	name = "Oscar outpost abandoned base"
	mappath = "_maps/modularmaps/oscaroutpost/oscarsouthvar3.dmm"
	modular_id = "oscarbase"
	template_width = 79
	template_height = 29

/datum/map_template/modular/oscaroutzetabasefour
	name = "Oscar outpost abandoned base"
	mappath = "_maps/modularmaps/oscaroutpost/oscarsouthvar4.dmm"
	modular_id = "oscarbase"
	template_width = 79
	template_height = 29

/datum/map_template/modular/oscaroutzetabasefive
	name = "Oscar outpost abandoned base"
	mappath = "_maps/modularmaps/oscaroutpost/oscarsouthvar5.dmm"
	modular_id = "oscarbase"
	template_width = 79
	template_height = 29

/datum/map_template/modular/oscaroutzetabasesix
	name = "Oscar outpost abandoned base"
	mappath = "_maps/modularmaps/oscaroutpost/oscarsouthvar6.dmm"
	modular_id = "oscarbase"
	template_width = 79
	template_height = 29

/datum/map_template/modular/oscaroutzetabaseseven
	name = "Oscar outpost abandoned base"
	mappath = "_maps/modularmaps/oscaroutpost/oscarsouthvar7.dmm"
	modular_id = "oscarbase"
	template_width = 79
	template_height = 29

/datum/map_template/modular/end_of_round/original
	name = "Original EORG"
	mappath = "_maps/modularmaps/EORG/original.dmm"
	modular_id = "EORG"
	template_width = 46
	template_height = 46

/datum/map_template/modular/end_of_round/de_dust2
	name = "de dust 2"
	mappath = "_maps/modularmaps/EORG/de_dust2.dmm"
	modular_id = "EORG"
	template_width = 46
	template_height = 46

/datum/map_template/modular/end_of_round/old
	name = "Old EORG"
	mappath = "_maps/modularmaps/EORG/old.dmm"
	modular_id = "EORG"
	template_width = 46
	template_height = 46

/datum/map_template/modular/end_of_round/basketball
	name = "Basketball Arena"
	mappath = "_maps/modularmaps/EORG/basketball.dmm"
	modular_id = "EORG"
	template_width = 46
	template_height = 46

/datum/map_template/modular/end_of_round/cs_mansion
	name = "cs mansion"
	mappath = "_maps/modularmaps/EORG/cs_mansion.dmm"
	modular_id = "EORG"
	template_width = 46
	template_height = 46

/datum/map_template/modular/end_of_round/cs_militia
	name = "cs militia"
	mappath = "_maps/modularmaps/EORG/cs_militia.dmm"
	modular_id = "EORG"
	template_width = 46
	template_height = 46

/datum/map_template/modular/end_of_round/cs_office
	name = "cs office"
	mappath = "_maps/modularmaps/EORG/cs_office.dmm"
	modular_id = "EORG"
	template_width = 46
	template_height = 46

/datum/map_template/modular/end_of_round/de_inferno
	name = "de inferno"
	mappath = "_maps/modularmaps/EORG/de_inferno.dmm"
	modular_id = "EORG"
	template_width = 46
	template_height = 46

/datum/map_template/modular/end_of_round/de_nuke
	name = "de nuke"
	mappath = "_maps/modularmaps/EORG/de_nuke.dmm"
	modular_id = "EORG"
	template_width = 46
	template_height = 46
