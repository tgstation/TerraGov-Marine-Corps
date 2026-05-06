#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "byondapi_cpp_wrappers.h"

#if defined(WIN32) && defined(_MSC_VER)
#pragma warning(disable : 4996)	// disable bogus deprecation warning
#endif

/*
	C++ wrapper defs
 */
ByondExtException::ByondExtException() {str = NULL;}
ByondExtException::ByondExtException(char const *msg) {str = msg ? strdup(msg) : NULL;}
ByondExtException::ByondExtException(ByondExtException const &other) {
	str = other.str ? strdup(other.str) : NULL;
}
ByondExtException::~ByondExtException() {free(str);}
ByondExtException& ByondExtException::operator=(ByondExtException const &other) {
	if(this != &other) {
		free(str);
		str = other.str ? strdup(other.str) : NULL;
	}
	return *this;
}
char const *ByondExtException::ToString() {return str;}


ByondValue::ByondValue() {ByondValue_Clear(this);}
ByondValue::ByondValue(ByondValueType type, u4c ref) {ByondValue_SetRef(this,type,ref);}
ByondValue::ByondValue(float f) {ByondValue_SetNum(this,f);}
ByondValue::ByondValue(char const *str) {ByondValue_SetStr(this,str);}
#ifdef _STRING_
ByondValue::ByondValue(std::string &str) {ByondValue_SetStr(this,str.c_str());}
#endif
ByondValue::ByondValue(CByondValue const &src) {*this = src;}
ByondValue::ByondValue(ByondValue const &src) {*this = src;}

ByondValue &ByondValue::operator=(float f) {ByondValue_SetNum(this,f); return *this;}
ByondValue &ByondValue::operator=(char const *str) {ByondValue_SetStr(this,str); return *this;}
ByondValue &ByondValue::operator=(CByondValue const &src) {*(CByondValue*)this = src; return *this;}
bool ByondValue::operator==(CByondValue const &v) const {return ByondValue_Equals(this, &v);}
bool ByondValue::operator!=(CByondValue const &v) const {return !ByondValue_Equals(this, &v);}
ByondValue::operator bool() const {return ByondValue_IsTrue(this);}

void ByondValue::Clear() {ByondValue_Clear(this);}
ByondValueType ByondValue::GetType() const {return type;}

bool ByondValue::IsNull() const {return ByondValue_IsNull(this);}
bool ByondValue::IsNum() const {return ByondValue_IsNum(this);}
bool ByondValue::IsStr() const {return ByondValue_IsStr(this);}
bool ByondValue::IsList() const {return ByondValue_IsList(this);}
bool ByondValue::IsTrue() const {return ByondValue_IsTrue(this);}
bool ByondValue::IsType(char const *typestr) const {return ByondValue_IsType(this,typestr);}

float ByondValue::GetNum() const {return ByondValue_GetNum(this);}
u4c ByondValue::GetRef() const {return ByondValue_GetRef(this);}

void ByondValue::SetNum(float f) {ByondValue_SetNum(this,f);}
void ByondValue::SetStr(char const *str) {ByondValue_SetStr(this,str);}
void ByondValue::SetRef(ByondValueType type, u4c ref) {ByondValue_SetRef(this,type,ref);}

void ByondValue::IncRef() {ByondValue_IncRef(this);}
void ByondValue::DecRef() {ByondValue_DecRef(this);}
void ByondValue::DecTempRef() {ByondValue_DecTempRef(this);}
bool ByondValue::TestRef() {return Byond_TestRef(this);}

ByondValue &ByondValue::Swap(CByondValue &other) {
	CByondValue tmp = *this;
	*(CByondValue*)this = other;
	other = tmp;
	return *this;
}

bool ByondValue::ToString(char *buf, u4c *buflen) const {return Byond_ToString(this,buf,buflen);}
#ifdef _STRING_
std::string ByondValue::ToString() const {return Byond_ToString(*this);}
void ByondValue::ToString(std::string &result) const {Byond_ToString(*this,result);}
#endif

/*
	All of the C++-wrapped Byond_ functions throw ByondExtException on failure.
 */

ByondValue Byond_ReadVar(ByondValue const &loc, char const *varname) {
	ByondValue result;
	bool success = Byond_ReadVar(&loc, varname, &result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}
ByondValue Byond_ReadVarByStrId(ByondValue const &loc, u4c varname) {
	ByondValue result;
	bool success = Byond_ReadVarByStrId(&loc, varname, &result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}
void Byond_WriteVar(ByondValue const &loc, char const *varname, ByondValue val) {
	bool success = Byond_WriteVar(&loc, varname, &val);
	if(!success) throw ByondExtException(Byond_LastError());
}
void Byond_WriteVarByStrId(ByondValue const &loc, u4c varname, ByondValue val) {
	bool success = Byond_WriteVarByStrId(&loc, varname, &val);
	if(!success) throw ByondExtException(Byond_LastError());
}

bool Byond_ReadList(ByondValue const &loc, CByondValue *list, u4c *len) {
	bool success = Byond_ReadList(&loc, list, len);
	if(!success && !*len) throw ByondExtException(Byond_LastError());
	return success;
}
void Byond_WriteList(ByondValue const &loc, CByondValue const *list, u4c len) {
	bool success = Byond_WriteList(&loc, list, len);
	if(!success) throw ByondExtException(Byond_LastError());
}
bool Byond_ReadListAssoc(ByondValue const &loc, CByondValue *list, u4c *len) {
	bool success = Byond_ReadList(&loc, list, len);
	if(!success && !*len) throw ByondExtException(Byond_LastError());
	return success;
}

#ifdef _VECTOR_
void Byond_ReadList(ByondValue const &loc, std::vector<CByondValue> &list) {
	list.resize(list.capacity());
	u4c len=list.size();
	while(!Byond_ReadList(&loc, list.data(), &len)) {
		if(!len) throw ByondExtException(Byond_LastError());
		list.resize(len);
	}
	list.resize(len);
}
void Byond_WriteList(ByondValue const &loc, std::vector<CByondValue> const &list) {
	bool success = Byond_WriteList(&loc, list.data(), list.size());
	if(!success) throw ByondExtException(Byond_LastError());
}
void Byond_ReadListAssoc(ByondValue const &loc, std::vector<CByondValue> &list) {
	list.resize(list.capacity());
	u4c len=list.size();
	while(!Byond_ReadListAssoc(&loc, list.data(), &len)) {
		if(!len) throw ByondExtException(Byond_LastError());
		list.resize(len);
	}
	list.resize(len);
}
#endif

ByondValue Byond_ReadListIndex(ByondValue const &loc, ByondValue const &idx) {
	ByondValue result;
	bool success = Byond_ReadListIndex(&loc, &idx, &result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}
void Byond_WriteListIndex(ByondValue const &loc, ByondValue const &idx, ByondValue const &val) {
	bool success = Byond_WriteListIndex(&loc, &idx, &val);
	if(!success) throw ByondExtException(Byond_LastError());
}

ByondValue Byond_CreateList() {
	ByondValue result;
	bool success = Byond_CreateList(&result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}
ByondValue Byond_CreateList(CByondValue const *list, u4c len) {
	ByondValue result;
	bool success = Byond_CreateList(&result);
	if(!success) throw ByondExtException(Byond_LastError());
	success = Byond_WriteList(&result, list, len);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}
#ifdef _VECTOR_
ByondValue Byond_CreateList(std::vector<CByondValue> const &list) {return Byond_CreateList(list.data(), list.size());}
#endif

ByondValue Byond_ReadPointer(ByondValue const &ptr) {
	ByondValue result;
	bool success = Byond_ReadPointer(&ptr, &result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}
void Byond_WritePointer(ByondValue const &ptr, ByondValue val) {
	bool success = Byond_WritePointer(&ptr, &val);
	if(!success) throw ByondExtException(Byond_LastError());
}

ByondValue Byond_CallProc(ByondValue const &src, char const *name, CByondValue const *arg, u4c arg_count) {
	ByondValue result;
	bool success = Byond_CallProc(&src,name,arg,arg_count,&result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}

ByondValue Byond_CallProcByStrId(ByondValue const &src, u4c name, CByondValue const *arg, u4c arg_count) {
	ByondValue result;
	bool success = Byond_CallProcByStrId(&src,name,arg,arg_count,&result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}

ByondValue Byond_CallGlobalProc(char const *name, CByondValue const *arg, u4c arg_count) {
	ByondValue result;
	bool success = Byond_CallGlobalProc(name,arg,arg_count,&result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}

ByondValue Byond_CallGlobalProcByStrId(u4c name, CByondValue const *arg, u4c arg_count) {
	ByondValue result;
	bool success = Byond_CallGlobalProcByStrId(name,arg,arg_count,&result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}

bool Byond_ToString(CByondValue const &src, char *buf, u4c *buflen) {
	bool success = Byond_ToString(&src,buf,buflen);
	if(!success && !*buflen) throw ByondExtException(Byond_LastError());
	return success;
}
#ifdef _STRING_
std::string Byond_ToString(CByondValue const &src) {
	std::string result;
	u4c len=result.capacity();
	while(!Byond_ToString(&src, const_cast<char*>(result.data()), &len)) {
		if(!len) throw ByondExtException(Byond_LastError());
		result.reserve(len);
	}
	result.assign(result.data(), len-1);
	return result;
}
void Byond_ToString(CByondValue const &src, std::string &result) {
	u4c len=result.capacity();
	while(!Byond_ToString(&src, const_cast<char*>(result.data()), &len)) {
		if(!len) throw ByondExtException(Byond_LastError());
		result.reserve(len);
	}
	result.assign(result.data(), len-1);
}
#endif

bool Byond_Return(ByondValue const &waiting_proc, ByondValue const &retval) {return Byond_Return(&waiting_proc,&retval);}

// builtins
bool Byond_Block(CByondXYZ const &corner1, CByondXYZ const &corner2, CByondValue *list, u4c *len) {
	bool success = Byond_Block(&corner1,&corner2,list,len);
	if(!success && !*len) throw ByondExtException(Byond_LastError());
	return success;
}
#ifdef _VECTOR_
void Byond_Block(CByondXYZ const &corner1, CByondXYZ const &corner2, std::vector<CByondValue> &list) {
	list.resize(list.capacity());
	u4c len=list.size();
	while(!Byond_Block(&corner1, &corner2, list.data(), &len)) {
		if(!len) throw ByondExtException(Byond_LastError());
		list.resize(len);
	}
	list.resize(len);
}
#endif

bool ByondValue_IsType(ByondValue const &src, char const *typestr) {
	return ByondValue_IsType(&src,typestr);
}

ByondValue Byond_Length(ByondValue const &src) {
	ByondValue result;
	bool success = Byond_Length(&src,&result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}

ByondValue Byond_Locate(ByondValue const &type) {
	ByondValue result;
	bool success = Byond_LocateIn(&type, NULL, &result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}

ByondValue Byond_LocateIn(ByondValue const &type, ByondValue const &list) {
	ByondValue result;
	bool success = Byond_LocateIn(&type, &list, &result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}

ByondValue Byond_LocateXYZ(CByondXYZ const &xyz) {
	ByondValue result;
	Byond_LocateXYZ(&xyz, &result);	// return value is always true
	return result;
}

ByondValue Byond_New(ByondValue const &src, CByondValue const *arg, u4c arg_count) {
	ByondValue result;
	bool success = Byond_New(&src,arg,arg_count,&result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}

ByondValue Byond_NewArglist(ByondValue const &src, ByondValue const &arglist) {
	ByondValue result;
	bool success = Byond_NewArglist(&src,&arglist,&result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}

u4c Byond_Refcount(ByondValue const &src) {
	u4c result;
	bool success = Byond_Refcount(&src,&result);
	if(!success) throw ByondExtException(Byond_LastError());
	return result;
}

CByondXYZ Byond_XYZ(ByondValue const &src) {
	CByondXYZ xyz;
	bool success = Byond_XYZ(&src,&xyz);
	if(!success) throw ByondExtException(Byond_LastError());
	return xyz;
}

CByondPixLoc Byond_PixLoc(ByondValue const &src) {
	CByondPixLoc pixloc;
	bool success = Byond_PixLoc(&src,&pixloc);
	if(!success) throw ByondExtException(Byond_LastError());
	return pixloc;
}

CByondPixLoc Byond_BoundPixLoc(ByondValue const &src, u1c dir) {
	CByondPixLoc pixloc;
	bool success = Byond_BoundPixLoc(&src,dir,&pixloc);
	if(!success) throw ByondExtException(Byond_LastError());
	return pixloc;
}
