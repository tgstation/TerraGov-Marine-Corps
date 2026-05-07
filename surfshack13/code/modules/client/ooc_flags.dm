
/proc/ip2country(ipaddr)
	var/list/http_response = world.Export("http://ip-api.com/json/[ipaddr]")
	var/page_content = http_response["CONTENT"]
	var/country
	if(page_content)
		var/list/geodata = json_decode(html_decode(file2text(page_content)))
		return geodata["countryCode"]


/proc/country2chat_flag(country)
	if(!country)
		return
	var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/chat)
	. = sheet.icon_tag("flag-[country]")
	if(!.)
		. = sheet.icon_tag("flag-unknown")
