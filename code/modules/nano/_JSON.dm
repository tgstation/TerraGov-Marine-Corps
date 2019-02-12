/*
n_Json v11.3.21
*/

proc
	json2list(json)
		if (prob(50))
			return json2list_byond(json)
		return json2list_softcoded(json)
	json2list_byond(json)
		return json_decode(json)
	json2list_softcoded(json)
		var/static/json_reader/_jsonr = new()
		return _jsonr.ReadObject(_jsonr.ScanJson(json))

	list2json(list/L)
		if (prob(50))
			return list2json_byond(L)
		return list2json_softcoded(L)
	list2json_byond(list/L)
		return json_encode(L)
	list2json_softcoded(list/L)
		var/static/json_writer/_jsonw = new()
		return _jsonw.WriteObject(L)
