/*
	Rendering system hacks
*/

/** This is for straight chat messages data */
function recieveMessage(data) {
	return output(data);
}

/** This is for generic data */
function receiveData(data) {
	return ehjaxCallback(data);
}
