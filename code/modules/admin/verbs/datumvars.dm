#define VV_MSG_MARKED "<br><font size='1' color='red'><b>Marked Object</b></font>"
#define VV_MSG_EDITED "<br><font size='1' color='red'><b>Var Edited</b></font>"
#define VV_MSG_DELETED "<br><font size='1' color='red'><b>Deleted</b></font>"


/datum/proc/CanProcCall(procname)
	return TRUE


/datum/proc/can_vv_get(var_name)
	return TRUE

/client/can_vv_get(var_name)
	if(var_name != "address" && var_name != "computer_id" || check_rights(R_DEBUG))
		return TRUE
	return FALSE


/datum/proc/vv_edit_var(var_name, var_value) //called whenever a var is edited
	if(var_name == NAMEOF(src, vars))
		return FALSE
	vars[var_name] = var_value
	datum_flags |= DF_VAR_EDITED
	return TRUE


/datum/proc/vv_get_var(var_name)
	switch(var_name)
		if("vars")
			return debug_variable(var_name, list(), 0, src)
	return debug_variable(var_name, vars[var_name], 0, src)


/proc/get_all_of_type(T, subtypes = TRUE)
	var/list/typecache = list()
	typecache[T] = 1
	if(subtypes)
		typecache = typecacheof(typecache)
	. = list()
	if(ispath(T, /mob))
		for(var/mob/thing in GLOB.mob_list)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /obj/machinery/door))
		for(var/obj/machinery/door/thing in GLOB.machines)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /obj/machinery))
		for(var/obj/machinery/thing in GLOB.machines)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /obj))
		for(var/obj/thing in world)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /atom/movable))
		for(var/atom/movable/thing in world)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /turf))
		for(var/turf/thing in world)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /atom))
		for(var/atom/thing in world)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /client))
		for(var/client/thing in GLOB.clients)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else if(ispath(T, /datum))
		for(var/datum/thing)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK

	else
		for(var/datum/thing in world)
			if(typecache[thing.type])
				. += thing
			CHECK_TICK


/proc/make_types_fancy(list/types)
	if(ispath(types))
		types = list(types)
	. = list()
	for(var/type in types)
		var/typename = "[type]"
		var/static/list/TYPES_SHORTCUTS = list(
			/obj/effect/decal/cleanable = "CLEANABLE",
			/obj/item/radio/headset = "HEADSET",
			/obj/item/reagent_containers/food/drinks = "DRINK", //longest paths comes first
			/obj/item/reagent_containers/food = "FOOD",
			/obj/item/reagent_containers = "REAGENT_CONTAINERS",
			/obj/item/organ = "ORGAN",
			/obj/item = "ITEM",
			/obj/machinery = "MACHINERY",
			/obj/effect = "EFFECT",
			/obj = "O",
			/datum = "D",
			/turf/open = "OPEN",
			/turf/closed = "CLOSED",
			/turf = "T",
			/mob/living/carbon/human = "HUMAN",
			/mob/living/carbon = "CARBON",
			/mob/living/simple_animal = "SIMPLE",
			/mob/living = "LIVING",
			/mob = "M"
		)
		for (var/tn in TYPES_SHORTCUTS)
			if(copytext(typename, 1, length("[tn]/") + 1) == "[tn]/" /*findtextEx(typename,"[tn]/",1,2)*/ )
				typename = TYPES_SHORTCUTS[tn] + copytext(typename, length("[tn]/"))
				break
		.[typename] = type


/proc/get_fancy_list_of_atom_types()
	var/static/list/pre_generated_list
	if(!pre_generated_list) //init
		pre_generated_list = make_types_fancy(typesof(/atom))
	return pre_generated_list


/proc/get_fancy_list_of_datum_types()
	var/static/list/pre_generated_list
	if(!pre_generated_list) //init
		pre_generated_list = make_types_fancy(sortList(typesof(/datum) - typesof(/atom)))
	return pre_generated_list


/proc/filter_fancy_list(list/L, filter as text)
	var/list/matches = new
	for(var/key in L)
		var/value = L[key]
		if(findtext("[key]", filter) || findtext("[value]", filter))
			matches[key] = value
	return matches


//please call . = ..() first and append to the result, that way parent items are always at the top and child items are further down
//add separaters by doing . += "---"
/datum/proc/vv_get_dropdown()
	. = list()
	. += "---"
	.["Call Proc"] = "?_src_=vars;[HrefToken()];[VV_HK_CALLPROC]=[REF(src)]"
	.["Mark Object"] = "?_src_=vars;[HrefToken()];[VV_HK_MARK]=[REF(src)]"
	.["Delete"] = "?_src_=vars;[HrefToken()];[VV_HK_DELETE]=[REF(src)]"
	.["Show VV To Player"] = "?_src_=vars;[HrefToken()];[VV_HK_EXPOSE]=[REF(src)]"


/client/proc/debug_variables(datum/D in world)
	set category = "Debug"
	set name = "View Variables"

	if(!check_rights(R_VAREDIT))
		return

	var/static/cookieoffset = rand(1, 9999) //to force cookies to reset after the round.

	if(!D)
		return

	var/islist = islist(D)
	if(!islist && !istype(D))
		return

	var/title = ""
	var/refid = REF(D)
	var/icon/sprite
	var/hash

	var/type = /list
	if(!islist)
		type = D.type



	if(istype(D, /atom))
		var/atom/AT = D
		if(AT.icon && AT.icon_state)
			sprite = new /icon(AT.icon, AT.icon_state)
			hash = md5(AT.icon)
			hash = md5(hash + AT.icon_state)
			src << browse_rsc(sprite, "vv[hash].png")

	title = "[D] ([REF(D)]) = [type]"
	var/formatted_type = replacetext("[type]", "/", "<wbr>/")

	var/sprite_text
	if(sprite)
		sprite_text = "<img src='vv[hash].png'></td><td>"
	var/list/atomsnowflake = list()

	if(istype(D, /atom))
		var/atom/A = D
		if(ismob(A))
			atomsnowflake += "<a href='?_src_=vars;[HrefToken()];rename=[refid]'><b id='name'>[D]</b></a>"
		else
			atomsnowflake += "<a href='?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=name'><b id='name'>[D]</b></a>"
			atomsnowflake += "<br><font size='1'><a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=left'><<</a> <a href='?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(A.dir) || A.dir]</a> <a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=right'>>></a></font>"
		if(isliving(A))
			atomsnowflake += "<br><font size='1'><a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=left'><<</a> <a href='?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(A.dir) || A.dir]</a> <a href='?_src_=vars;[HrefToken()];rotatedatum=[refid];rotatedir=right'>>></a></font>"
			var/mob/living/M = A
			atomsnowflake += {"
				<br><font size='1'><a href='?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=ckey' id='ckey'>[M.ckey || "No ckey"]</a> / <a href='?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=real_name' id='real_name'>[M.real_name || "No real name"]</a></font>
				<br><font size='1'>
					BRUTE:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=brute' id='brute'>[M.getBruteLoss()]</a>
					FIRE:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=fire' id='fire'>[M.getFireLoss()]</a>
					TOXIN:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=toxin' id='toxin'>[M.getToxLoss()]</a>
					OXY:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=oxygen' id='oxygen'>[M.getOxyLoss()]</a>
					CLONE:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=clone' id='clone'>[M.getCloneLoss()]</a>
					BRAIN:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=brain' id='brain'>[M.getBrainLoss()]</a>
					STAMINA:<font size='1'><a href='?_src_=vars;[HrefToken()];mobToDamage=[refid];adjustDamage=stamina' id='stamina'>[M.getStaminaLoss()]</a>
				</font>
			"}
	else if("name" in D.vars)
		atomsnowflake += "<a href='?_src_=vars;[HrefToken()];datumedit=[refid];varnameedit=name'><b id='name'>[D]</b></a>"
	else
		atomsnowflake += "<b>[formatted_type]</b>"
		formatted_type = null

	var/marked
	if(holder?.marked_datum && holder.marked_datum == D)
		marked = VV_MSG_MARKED
	var/varedited_line = ""
	if(!islist && (D.datum_flags & DF_VAR_EDITED))
		varedited_line = VV_MSG_EDITED
	var/deleted_line
	if(!islist && D.gc_destroyed)
		deleted_line = VV_MSG_DELETED

	var/list/dropdownoptions = list()
	if(islist)
		dropdownoptions = list(
			"---",
			"Add Item" = "?_src_=vars;[HrefToken()];listadd=[refid]",
			"Remove Nulls" = "?_src_=vars;[HrefToken()];listnulls=[refid]",
			"Remove Dupes" = "?_src_=vars;[HrefToken()];listdupes=[refid]",
			"Set len" = "?_src_=vars;[HrefToken()];listlen=[refid]",
			"Shuffle" = "?_src_=vars;[HrefToken()];listshuffle=[refid]",
			"Show VV To Player" = "?_src_=vars;[HrefToken()];expose=[refid]"
			)
	else
		dropdownoptions = D.vv_get_dropdown()
	var/list/dropdownoptions_html = list()

	for(var/name in dropdownoptions)
		var/link = dropdownoptions[name]
		if(link)
			dropdownoptions_html += "<option value='[link]'>[name]</option>"
		else
			dropdownoptions_html += "<option value>[name]</option>"

	var/list/names = list()
	if(!islist)
		for(var/V in D.vars)
			names += V
	sleep(0.1 SECONDS)//For some reason, without this sleep, VVing will cause client to disconnect on certain objects.

	var/list/variable_html = list()
	if(islist)
		var/list/L = D
		for(var/i in 1 to length(L))
			var/key = L[i]
			var/value
			if(IS_NORMAL_LIST(L) && !isnum(key))
				value = L[key]
			variable_html += debug_variable(i, value, 0, D)
	else

		names = sortList(names)
		for (var/V in names)
			if(D.can_vv_get(V))
				variable_html += D.vv_get_var(V)

	var/html = {"
<html>
	<head>
		<title>[title]</title>
		<style>
			body {
				font-family: Verdana, sans-serif;
				font-size: 9pt;
			}
			.value {
				font-family: "Courier New", monospace;
				font-size: 8pt;
			}
		</style>
	</head>
	<body onload='selectTextField()' onkeydown='return handle_keydown()' onkeyup='handle_keyup()'>
		<script type="text/javascript">
			// onload
			function selectTextField() {
				var filter_text = document.getElementById('filter');
				filter_text.focus();
				filter_text.select();
				var lastsearch = getCookie("[refid][cookieoffset]search");
				if(lastsearch) {
					filter_text.value = lastsearch;
					updateSearch();
				}
			}
			function getCookie(cname) {
				var name = cname + "=";
				var ca = document.cookie.split(';');
				for(var i=0; i<ca.length; i++) {
					var c = ca\[i];
					while (c.charAt(0)==' ') c = c.substring(1,c.length);
					if(c.indexOf(name)==0) return c.substring(name.length,c.length);
				}
				return "";
			}

			// main search functionality
			var last_filter = "";
			function updateSearch() {
				var filter = document.getElementById('filter').value.toLowerCase();
				var vars_ol = document.getElementById("vars");

				if(filter === last_filter) {
					// An event triggered an update but nothing has changed.
					return;
				} else if(filter.indexOf(last_filter) === 0) {
					// The new filter starts with the old filter, fast path by removing only.
					var children = vars_ol.childNodes;
					for (var i = children.length - 1; i >= 0; --i) {
						try {
							var li = children\[i];
							if(li.innerText.toLowerCase().indexOf(filter) == -1) {
								vars_ol.removeChild(li);
							}
						} catch(err) {}
					}
				} else {
					// Remove everything and put back what matches.
					while (vars_ol.hasChildNodes()) {
						vars_ol.removeChild(vars_ol.lastChild);
					}

					for (var i = 0; i < complete_list.length; ++i) {
						try {
							var li = complete_list\[i];
							if(!filter || li.innerText.toLowerCase().indexOf(filter) != -1) {
								vars_ol.appendChild(li);
							}
						} catch(err) {}
					}
				}

				last_filter = filter;
				document.cookie="[refid][cookieoffset]search="+encodeURIComponent(filter);

				var lis_new = vars_ol.getElementsByTagName("li");
				for (var j = 0; j < lis_new.length; ++j) {
					lis_new\[j].style.backgroundColor = (j == 0) ? "#ffee88" : "white";
				}
			}

			// onkeydown
			function handle_keydown() {
				if(event.keyCode == 116) {  //F5 (to refresh properly)
					document.getElementById("refresh_link").click();
					event.preventDefault ? event.preventDefault() : (event.returnValue = false);
					return false;
				}
				return true;
			}

			// onkeyup
			function handle_keyup() {
				if(event.keyCode == 13) {  //Enter / return
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for (var i = 0; i < lis.length; ++i) {
						try {
							var li = lis\[i];
							if(li.style.backgroundColor == "#ffee88") {
								alist = lis\[i].getElementsByTagName("a");
								if(alist.length > 0) {
									location.href=alist\[0].href;
								}
							}
						} catch(err) {}
					}
				} else if(event.keyCode == 38){  //Up arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for (var i = 0; i < lis.length; ++i) {
						try {
							var li = lis\[i];
							if(li.style.backgroundColor == "#ffee88") {
								if(i > 0) {
									var li_new = lis\[i-1];
									li.style.backgroundColor = "white";
									li_new.style.backgroundColor = "#ffee88";
									return
								}
							}
						} catch(err) {}
					}
				} else if(event.keyCode == 40) {  //Down arrow
					var vars_ol = document.getElementById('vars');
					var lis = vars_ol.getElementsByTagName("li");
					for (var i = 0; i < lis.length; ++i) {
						try {
							var li = lis\[i];
							if(li.style.backgroundColor == "#ffee88") {
								if((i+1) < lis.length) {
									var li_new = lis\[i+1];
									li.style.backgroundColor = "white";
									li_new.style.backgroundColor = "#ffee88";
									return
								}
							}
						} catch(err) {}
					}
				} else {
					updateSearch();
				}
			}

			// onchange
			function handle_dropdown(list) {
				var value = list.options\[list.selectedIndex].value;
				if(value !== "") {
					location.href = value;
				}
				list.selectedIndex = 0;
				document.getElementById('filter').focus();
			}

			// byjax
			function replace_span(what) {
				var idx = what.indexOf(':');
				document.getElementById(what.substr(0, idx)).innerHTML = what.substr(idx + 1);
			}
		</script>
		<div align='center'>
			<table width='100%'>
				<tr>
					<td width='50%'>
						<table align='center' width='100%'>
							<tr>
								<td>
									[sprite_text]
									<div align='center'>
										[atomsnowflake.Join()]
									</div>
								</td>
							</tr>
						</table>
						<div align='center'>
							<b><font size='1'>[formatted_type]</font></b>
							<span id='marked'>[marked]</span>
							<span id='varedited'>[varedited_line]</span>
							<span id='deleted'>[deleted_line]</span>
						</div>
					</td>
					<td width='50%'>
						<div align='center'>
							<a id='refresh_link' href='?_src_=vars;[HrefToken()];datumrefresh=[refid]'>Refresh</a>
							<form>
								<select name="file" size="1"
									onchange="handle_dropdown(this)"
									onmouseclick="this.focus()"
									style="background-color:#ffffff">
									<option value selected>Select option</option>
									[dropdownoptions_html.Join()]
								</select>
							</form>
						</div>
					</td>
				</tr>
			</table>
		</div>
		<hr>
		<font size='1'>
			<b>E</b> - Edit, tries to determine the variable type by itself.<br>
			<b>C</b> - Change, asks you for the var type first.<br>
			<b>M</b> - Mass modify: changes this variable for all objects of this type.<br>
		</font>
		<hr>
		<table width='100%'>
			<tr>
				<td width='20%'>
					<div align='center'>
						<b>Search:</b>
					</div>
				</td>
				<td width='80%'>
					<input type='text' id='filter' name='filter_text' value='' style='width:100%;'>
				</td>
			</tr>
		</table>
		<hr>
		<ol id='vars'>
			[variable_html.Join()]
		</ol>
		<script type='text/javascript'>
			var complete_list = \[\];
			var lis = document.getElementById("vars").children;
			for(var i = lis.length; i--;) complete_list\[i\] = lis\[i\];
		</script>
	</body>
</html>
"}
	src << browse(html, "window=variables[refid];size=475x650")


/client/proc/vv_update_display(datum/D, span, content)
	src << output("[span]:[content]", "variables[REF(D)].browser:replace_span")


#define VV_HTML_ENCODE(thing) (sanitize ? html_encode(thing) : thing)

/proc/debug_variable(name, value, level, datum/DA = null, sanitize = TRUE)
	var/header
	if(DA)
		if(islist(DA))
			var/index = name
			if(value)
				name = DA[name] //name is really the index until this line
			else
				value = DA[name]
			header = "<li style='backgroundColor:white'>(<a href='?_src_=vars;[HrefToken()];listedit=[REF(DA)];index=[index]'>E</a>) (<a href='?_src_=vars;[HrefToken()];listchange=[REF(DA)];index=[index]'>C</a>) (<a href='?_src_=vars;[HrefToken()];listremove=[REF(DA)];index=[index]'>-</a>) "
		else
			header = "<li style='backgroundColor:white'>(<a href='?_src_=vars;[HrefToken()];datumedit=[REF(DA)];varnameedit=[name]'>E</a>) (<a href='?_src_=vars;[HrefToken()];datumchange=[REF(DA)];varnamechange=[name]'>C</a>) (<a href='?_src_=vars;[HrefToken()];datummass=[REF(DA)];varnamemass=[name]'>M</a>) "
	else
		header = "<li>"

	var/item
	if(isnull(value))
		item = "[VV_HTML_ENCODE(name)] = [span_value("null")]"

	else if(istext(value))
		item = "[VV_HTML_ENCODE(name)] = [span_value("\"[VV_HTML_ENCODE(value)]\"")]"

	else if(isicon(value))
		item = "[VV_HTML_ENCODE(name)] = /icon ([span_value("[value]")])"

	else if(isfile(value))
		item = "[VV_HTML_ENCODE(name)] = [span_value("'[value]'")]"

	else if(istype(value, /datum))
		var/datum/D = value
		if("[D]" != "[D.type]") //if the thing as a name var, lets use it.
			item = "<a href='?_src_=vars;[HrefToken()];vars=[REF(value)]'>[VV_HTML_ENCODE(name)] [REF(value)]</a> = [D] [D.type]"
		else
			item = "<a href='?_src_=vars;[HrefToken()];vars=[REF(value)]'>[VV_HTML_ENCODE(name)] [REF(value)]</a> = [D.type]"

	else if(islist(value))
		var/list/L = value
		var/list/items = list()

		if(istype(DA, /datum/controller/global_vars) && !DA.vv_edit_var(name, L))
			item = "[VV_HTML_ENCODE(name)] = /list ([length(L)])"
		else if(length(L) > 0  && !(name == "underlays" || name == "overlays" || length(L) > (IS_NORMAL_LIST(L) ? 50 : 150)))
			for(var/i in 1 to length(L))
				var/key = L[i]
				var/val
				if(IS_NORMAL_LIST(L) && !isnum(key))
					val = L[key]
				if(isnull(val))	// we still want to display non-null false values, such as 0 or ""
					val = key
					key = i

				items += debug_variable(key, val, level + 1, sanitize = sanitize)

			item = "<a href='?_src_=vars;[HrefToken()];vars=[REF(value)]'>[VV_HTML_ENCODE(name)] = /list ([length(L)])</a><ul>[items.Join()]</ul>"
		else
			item = "<a href='?_src_=vars;[HrefToken()];vars=[REF(value)]'>[VV_HTML_ENCODE(name)] = /list ([length(L)])</a>"

	else if(name in GLOB.bitfields)
		var/list/flags = list()
		for(var/i in GLOB.bitfields[name])
			if(value & GLOB.bitfields[name][i])
				flags += i
			item = "[VV_HTML_ENCODE(name)] = [VV_HTML_ENCODE(jointext(flags, ", "))]"
	else
		item = "[VV_HTML_ENCODE(name)] = [span_value("[VV_HTML_ENCODE(value)]")]"

	return "[header][item]</li>"

#undef VV_HTML_ENCODE


/client/proc/view_var_Topic(href, href_list, hsrc)
	if(usr.client != src || !src.holder || !holder.CheckAdminHref(href, href_list))
		return


	if(href_list["vars"])
		debug_variables(locate(href_list["vars"]))


	else if(href_list["datumrefresh"])
		var/datum/DAT = locate(href_list["datumrefresh"])
		if(!DAT) //can't be an istype() because /client etc aren't datums
			return
		src.debug_variables(DAT)


	else if(href_list[VV_HK_MARK])
		if(!check_rights(R_DEBUG))
			return

		var/datum/D = locate(href_list[VV_HK_MARK])
		if(!istype(D))
			return
		mark_datum(D)


	else if(href_list["proc_call"])
		if(!check_rights(R_DEBUG))
			return

		var/T = locate(href_list["proc_call"])

		if(T)
			usr.client.holder.proccall_atom(T)


	else if(href_list["delete"])
		if(!check_rights(R_VAREDIT))
			return

		var/datum/D = locate(href_list["delete"])
		if(!istype(D))
			to_chat(usr, span_warning("Unable to locate item."))
		usr.client.holder.delete_atom(D)
		if(isturf(D))  // show the turf that took its place
			debug_variables(D)

	else if(href_list["regenerateicons"])
		if(!check_rights(R_DEBUG))
			return

		var/mob/M = locate(href_list["regenerateicons"]) in GLOB.mob_list
		if(!ismob(M))
			return
		M.regenerate_icons()


	else if(href_list["expose"])
		if(!check_rights(R_ADMIN, FALSE))
			return

		var/thing = locate(href_list["expose"])
		if(!thing)
			return

		var/value = vv_get_value(VV_CLIENT)
		if(value["class"] != VV_CLIENT)
			return

		var/client/C = value["value"]
		if(!C)
			return

		var/prompt = alert("Do you want to grant [C] access to view this VV window? (they will not be able to edit or change anything nor open nested vv windows unless they themselves are an admin)", "Confirm", "Yes", "No")
		if(prompt != "Yes" || !usr.client)
			return

		to_chat(C, "[usr.client.holder.fakekey ? "an Administrator" : "[usr.client.key]"] has granted you access to view a View Variables window")
		C.debug_variables(thing)

		log_admin("Admin [key_name(usr)] showed [key_name(C)] a VV window of: [thing].")
		message_admins("[ADMIN_TPMONTY(usr)] showed [key_name_admin(C)] a <a href='?_src_=vars;[HrefToken(TRUE)];datumrefresh=[REF(thing)]'>VV window</a>.")


	if(href_list["rename"])
		if(!check_rights(R_VAREDIT))
			return

		var/mob/M = locate(href_list["rename"]) in GLOB.mob_list
		if(!istype(M))
			return

		var/old_name = M.real_name
		var/new_name = input(usr, "What would you like to name this mob?", "Input a name", M.real_name) as text
		new_name = noscript(new_name)
		if(!new_name || !M)
			return

		M.fully_replace_character_name(M.real_name, new_name)
		vv_update_display(M, "name", new_name)
		vv_update_display(M, "real_name", M.real_name || "No real name")

		log_admin("[key_name(usr)] renamed [old_name] to [key_name(M)].")
		message_admins("[ADMIN_TPMONTY(usr)] renamed [old_name] to [ADMIN_TPMONTY(M)].")


	else if(href_list["varnameedit"] && href_list["datumedit"])
		if(!check_rights(R_VAREDIT))
			return

		var/datum/D = locate(href_list["datumedit"])
		if(!istype(D, /datum))
			return

		if(!modify_variables(D, href_list["varnameedit"], 1))
			return

		switch(href_list["varnameedit"])
			if("name")
				vv_update_display(D, "name", "[D]")
			if("dir")
				if(isatom(D))
					var/dir = D.vars["dir"]
					vv_update_display(D, "dir", dir2text(dir) || dir)
			if("ckey")
				if(isliving(D))
					vv_update_display(D, "ckey", D.vars["ckey"] || "No ckey")
			if("real_name")
				if(isliving(D))
					vv_update_display(D, "real_name", D.vars["real_name"] || "No real name")


	else if(href_list["varnamechange"] && href_list["datumchange"])
		if(!check_rights(R_VAREDIT))
			return

		var/D = locate(href_list["datumchange"])
		if(!istype(D, /datum))
			return

		modify_variables(D, href_list["varnamechange"], 0)


	else if(href_list["varnamemass"] && href_list["datummass"])
		if(!check_rights(R_VAREDIT))
			return

		var/datum/D = locate(href_list["datummass"])
		if(!istype(D))
			return

		mass_modify(D, href_list["varnamemass"])


	else if(href_list["listedit"] && href_list["index"])
		var/index = text2num(href_list["index"])
		if(!index)
			return

		var/list/L = locate(href_list["listedit"])
		if(!istype(L))
			return

		mod_list(L, null, "list", "contents", index, autodetect_class = TRUE)


	else if(href_list["listchange"] && href_list["index"])
		var/index = text2num(href_list["index"])
		if(!index)
			return

		var/list/L = locate(href_list["listchange"])
		if(!istype(L))
			return

		mod_list(L, null, "list", "contents", index, autodetect_class = FALSE)


	else if(href_list["listremove"] && href_list["index"])
		var/index = text2num(href_list["index"])
		if(!index)
			return

		var/list/L = locate(href_list["listremove"])
		if(!istype(L))
			return

		var/variable = L[index]
		var/prompt = alert("Do you want to remove item number [index] from list?", "Confirm", "Yes", "No")
		if(prompt != "Yes")
			return

		L.Cut(index, index + 1)

		log_world("### ListVarEdit by [src]: /list's contents: REMOVED=[html_encode("[variable]")]")
		log_admin("[key_name(src)] modified list's contents: REMOVED=[variable]")
		message_admins("[ADMIN_TPMONTY(usr)] modified list's contents: REMOVED=[variable]")


	else if(href_list["listadd"])
		var/list/L = locate(href_list["listadd"])
		if(!istype(L))
			return

		mod_list_add(L, null, "list", "contents")


	else if(href_list["listdupes"])
		var/list/L = locate(href_list["listdupes"])
		if(!istype(L))
			return

		uniqueList_inplace(L)
		log_world("### ListVarEdit by [src]: /list contents: CLEAR DUPES")
		log_admin("[key_name(src)] modified list's contents: CLEAR DUPES")
		message_admins("[ADMIN_TPMONTY(usr)] modified list's contents: CLEAR DUPES")


	else if(href_list["listnulls"])
		var/list/L = locate(href_list["listnulls"])
		if(!istype(L))
			return

		listclearnulls(L)
		log_world("### ListVarEdit by [src]: /list contents: CLEAR NULLS")
		log_admin("[key_name(src)] modified list's contents: CLEAR NULLS")
		message_admins("[ADMIN_TPMONTY(usr)] modified list's contents: CLEAR NULLS")


	else if(href_list["listlen"])
		var/list/L = locate(href_list["listlen"])
		if(!istype(L))
			return
		var/value = vv_get_value(VV_NUM)
		if(value["class"] != VV_NUM)
			return

		L.len = value["value"]
		log_world("### ListVarEdit by [src]: /list len: [length(L)]")
		log_admin("[key_name(src)] modified list's len: [length(L)]")
		message_admins("[ADMIN_TPMONTY(usr)] modified list's len: [length(L)]")


	else if(href_list["listshuffle"])
		var/list/L = locate(href_list["listshuffle"])
		if(!istype(L))
			return

		shuffle_inplace(L)
		log_world("### ListVarEdit by [src]: /list contents: SHUFFLE")
		log_admin("[key_name(src)] modified list's contents: SHUFFLE")
		message_admins("[ADMIN_TPMONTY(usr)] modified list's contents: SHUFFLE")


	else if(href_list["delall"])
		if(!check_rights(R_DEBUG|R_SERVER))
			return

		var/obj/O = locate(href_list["delall"])
		if(!isobj(O))
			return

		var/action_type = alert("Strict type ([O.type]) or type and all subtypes?", "Type", "Strict type", "Type and subtypes", "Cancel")
		if(action_type == "Cancel" || !action_type)
			return

		if(alert("Are you really sure you want to delete all objects of type [O.type]?", "Warning", "Yes", "No") != "Yes")
			return

		if(alert("Second confirmation required. Delete?", "Warning", "Yes", "No") != "Yes")
			return

		var/O_type = O.type
		var/i = 0
		var/strict
		switch(action_type)
			if("Strict type")
				strict = TRUE
				for(var/obj/Obj in world)
					if(Obj.type == O_type)
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return
			if("Type and subtypes")
				for(var/obj/Obj in world)
					if(istype(Obj,O_type))
						i++
						qdel(Obj)
					CHECK_TICK
				if(!i)
					to_chat(usr, "No objects of this type exist")
					return

		log_admin("[key_name(usr)] deleted all objects of type[strict ? "" : " and subtypes"] of [O_type] ([i] objects deleted).")
		message_admins("[ADMIN_TPMONTY(usr)] deleted all objects of type[strict ? "" : " and subtypes"] of [O_type] ([i] objects deleted).")


	else if(href_list["addreagent"])
		if(!check_rights(R_VAREDIT))
			return

		var/atom/A = locate(href_list["addreagent"])

		if(!A.reagents)
			var/amount = input(usr, "Specify the reagent size of [A]", "Set Reagent Size", 50) as num
			if(amount)
				A.create_reagents(amount)

		if(A.reagents)
			var/chosen_id
			var/list/reagent_options = sortList(GLOB.chemical_reagents_list)
			switch(alert(usr, "Choose a method.", "Add Reagents", "Enter ID", "Choose ID"))
				if("Enter ID")
					var/valid_id
					while(!valid_id)
						chosen_id = stripped_input(usr, "Enter the ID of the reagent you want to add.")
						if(!chosen_id) //Get me out of here!
							break
						for(var/ID in reagent_options)
							if(ID == chosen_id)
								valid_id = TRUE
						if(!valid_id)
							to_chat(usr, span_warning("A reagent with that ID doesn't exist!"))
				if("Choose ID")
					chosen_id = input(usr, "Choose a reagent to add.", "Add Reagent") as null|anything in reagent_options
			if(chosen_id)
				var/amount = input(usr, "Choose the amount to add.", "Add Reagent", A.reagents.maximum_volume) as num
				if(amount)
					A.reagents.add_reagent(chosen_id, amount)
					log_admin("[key_name(usr)] has added [amount] units of [chosen_id] to [A].")
					message_admins("[ADMIN_TPMONTY(usr)] has added [amount] units of [chosen_id] to [A].")

	else if(href_list["modify_greyscale"] && check_rights(R_DEBUG))
		var/datum/greyscale_modify_menu/menu = new(locate(href_list["modify_greyscale"]), usr)
		menu.ui_interact(usr)
		return

	else if(href_list["filteredit"] && check_rights(R_VAREDIT))
		var/client/C = usr.client
		C?.open_filter_editor(locate(href_list["filteredit"]))
		return

	if(href_list["modify_particles"] && check_rights(R_VAREDIT))
		var/client/C = usr.client
		C?.open_particle_editor(locate(href_list["modify_particles"]))

	else if(href_list["rotatedatum"])
		if(!check_rights(R_DEBUG))
			return

		var/atom/A = locate(href_list["rotatedatum"])
		if(!istype(A))
			to_chat(usr, "This can only be done to instances of type /atom")
			return

		switch(href_list["rotatedir"])
			if("right")
				A.setDir(turn(A.dir, -45))
			if("left")
				A.setDir(turn(A.dir, 45))

		vv_update_display(A, "dir", dir2text(A.dir))

		log_admin("[key_name(usr)] rotated [A].")


	else if(href_list["modtransform"])
		if(!check_rights(R_DEBUG))
			return

		var/atom/A = locate(href_list["modtransform"])
		if(!istype(A))
			return

		var/result = input(usr, "Choose the transformation to apply", "Modify Transform") as null|anything in list("Scale","Translate","Rotate")
		var/matrix/M = A.transform
		switch(result)
			if("Scale")
				var/x = input(usr, "Choose x mod", "Modify Transform") as null|num
				var/y = input(usr, "Choose y mod", "Modify Transform") as null|num
				if(x == 0 || y == 0)
					if(alert("You've entered 0 as one of the values, are you sure?", "Modify Transform", "Yes", "No") != "Yes")
						return
				if(!isnull(x) && !isnull(y))
					A.transform = M.Scale(x,y)
			if("Translate")
				var/x = input(usr, "Choose x mod", "Modify Transform") as null|num
				var/y = input(usr, "Choose y mod", "Modify Transform") as null|num
				if(x == 0 && y == 0)
					return
				if(!isnull(x) && !isnull(y))
					A.transform = M.Translate(x,y)
			if("Rotate")
				var/angle = input(usr, "Choose angle to rotate", "Modify Transform") as null|num
				if(angle == 0)
					if(alert("You've entered 0 as one of the values, are you sure?", "Warning", "Yes", "No") != "Yes")
						return
				if(!isnull(angle))
					A.transform = M.Turn(angle)

		log_admin("[key_name(usr)] has used [result] transformation on [A].")
		message_admins("[ADMIN_TPMONTY(usr)] has used [result] transformation on [A].")


	else if(href_list["adjustDamage"] && href_list["mobToDamage"])
		if(!check_rights(R_FUN))
			return

		var/mob/living/L = locate(href_list["mobToDamage"]) in GLOB.mob_list
		if(!istype(L))
			return

		var/Text = href_list["adjustDamage"]

		var/amount = input("Deal how much damage to mob? (Negative values here heal)","Adjust [Text]loss",0) as num

		if(!L)
			return

		var/newamt
		switch(Text)
			if(BRUTE)
				L.adjustBruteLoss(amount)
				newamt = L.getBruteLoss()
			if(BURN)
				L.adjustFireLoss(amount)
				newamt = L.getFireLoss()
			if(TOX)
				L.adjustToxLoss(amount)
				newamt = L.getToxLoss()
			if(OXY)
				L.adjustOxyLoss(amount)
				newamt = L.getOxyLoss()
			if("brain")
				L.adjustBrainLoss(amount)
				newamt = L.getBrainLoss()
			if(CLONE)
				L.adjustCloneLoss(amount)
				newamt = L.getCloneLoss()
			if(STAMINA)
				L.adjustStaminaLoss(amount)
				newamt = L.getStaminaLoss()

		if(amount == 0)
			return

		vv_update_display(L, Text, "[newamt]")
		admin_ticket_log(L, span_notice("[key_name(usr)] dealt [amount] amount of [Text] damage to [key_name(L)]"))
		log_admin("[key_name(usr)] dealt [amount] amount of [Text] damage to [key_name(L)]")
		message_admins("[ADMIN_TPMONTY(usr)] dealt [amount] amount of [Text] damage to [ADMIN_TPMONTY(L)]")


	else if(href_list["addlanguage"])
		if(!check_rights(R_FUN))
			return

		var/mob/living/L = locate(href_list["addlanguage"])
		if(!istype(L))
			return

		var/new_language = input("Please choose a language to add.", "Language") as null|anything in GLOB.all_languages
		if(!new_language)
			return

		if(!istype(L))
			to_chat(usr, span_warning("Mob doesn't exist anymore."))
			return

		L.grant_language(new_language)

		log_admin("[key_name(usr)] has added [new_language] to [key_name(L)].")
		message_admins("[ADMIN_TPMONTY(usr)] has added [new_language] to [ADMIN_TPMONTY(L)].")


	else if(href_list["remlanguage"])
		if(!check_rights(R_FUN))
			return

		var/mob/living/L = locate(href_list["remlanguage"])
		if(!istype(L))
			return

		if(!length(L.language_holder.languages))
			to_chat(usr, span_warning("This mob knows no languages."))
			return

		var/rem_language = input("Please choose a language to remove.", "Language", null) as null|anything in L.language_holder.languages

		if(!rem_language)
			return

		if(!L)
			to_chat(usr, span_warning("Mob doesn't exist anymore."))
			return

		L.remove_language(rem_language)

		log_admin("[key_name(usr)] has removed [rem_language] from [key_name(L)].")
		message_admins("[ADMIN_TPMONTY(usr)] has removed [rem_language] from [ADMIN_TPMONTY(L)].")


	else if(href_list["getatom"])
		if(!check_rights(R_DEBUG))
			return

		var/atom/movable/A = locate(href_list["getatom"])
		if(!istype(A))
			return

		var/turf/T = get_turf(usr)
		if(!istype(T))
			return

		A.forceMove(T)

		log_admin("[key_name(usr)] has sent atom [A] to themselves.")
		message_admins("[ADMIN_TPMONTY(usr)] has sent atom [A] to themselves.")


	else if(href_list["sendatom"])
		if(!check_rights(R_DEBUG))
			return

		var/atom/movable/A = locate(href_list["sendatom"])
		if(!istype(A))
			return

		var/atom/target

		switch(input("Where do you want to send it to?", "Send Mob") as null|anything in list("Area", "Mob", "Key", "Coords"))
			if("Area")
				var/area/AR = input("Pick an area.", "Pick an area") as null|anything in GLOB.sorted_areas
				if(!AR || !A)
					return
				target = pick(get_area_turfs(AR))
			if("Mob")
				var/mob/N = input("Pick a mob.", "Pick a mob") as null|anything in sortList(GLOB.mob_list)
				if(!N || !A)
					return
				target = get_turf(N)
			if("Key")
				var/client/C = input("Pick a key.", "Pick a key") as null|anything in sortKey(GLOB.clients)
				if(!C || !A)
					return
				target = get_turf(C.mob)
			if("Coords")
				var/X = input("Select coordinate X", "Coordinate X") as null|num
				var/Y = input("Select coordinate Y", "Coordinate Y") as null|num
				var/Z = input("Select coordinate Z", "Coordinate Z") as null|num
				if(isnull(X) || isnull(Y) || isnull(Z) || !A)
					return
				target = locate(X, Y, Z)

		if(!target)
			return

		A.forceMove(target)

		log_admin("[key_name(usr)] has sent atom [A] to [AREACOORD(target)].")
		message_admins("[ADMIN_TPMONTY(usr)] has sent atom [A] to [ADMIN_VERBOSEJMP(target)].")

	else if(href_list["dropeverything"])
		if(!check_rights(R_DEBUG))
			return

		var/mob/living/carbon/human/H = locate(href_list["copyoutfit"])
		if(!istype(H))
			return

		if(alert(usr, "Make [H] drop everything?", "Warning", "Yes", "No") != "Yes")
			return

		for(var/obj/item/W in H)
			if(istype(W, /obj/item/alien_embryo))
				continue
			H.dropItemToGround(W)

		log_admin("[key_name(usr)] made [key_name(H)] drop everything.")
		message_admins("[ADMIN_TPMONTY(usr)] made [ADMIN_TPMONTY(H)] drop everything.")


	else if(href_list["updateicon"])
		if(!check_rights(R_DEBUG))
			return

		var/atom/movable/AM = locate(href_list["updateicon"])
		if(!istype(AM))
			return

		AM.update_icon()

		log_admin("[key_name(usr)] updated the icon of [AM].")


	else if(href_list["playerpanel"])
		if(!check_rights(R_BAN))
			return

		var/mob/M = locate(href_list["playerpanel"])
		if(!istype(M))
			to_chat(usr, span_warning("Target is no longer valid."))
			return

		usr.client.holder.show_player_panel(M)
