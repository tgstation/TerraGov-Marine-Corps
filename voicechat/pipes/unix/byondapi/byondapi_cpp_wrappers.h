#ifndef BYONDAPI_WRAPPERS_H
#define BYONDAPI_WRAPPERS_H

#include "byondapi.h"

/*
	C++ wrapper classes
 */

class ByondExtException {
	char *str;
	public:
	ByondExtException();
	ByondExtException(char const *msg);
	ByondExtException(ByondExtException const &other);
	~ByondExtException();
	ByondExtException& operator=(ByondExtException const &other);
	char const *ToString();
};

/*
	ByondValue is a wrapper class for CByondValue that takes care of the init,
	free, and assignment stuff for you.

	Because byondapi is limited to C structures, you can't return a ByondValue
	directly from your function. Instead, you need to call Detach(). Example:

	extern "C" BYOND_EXPORT CByondValue MyFunction(int n, ByondValue args[]) {
		ByondValue return_value;
		...	// function body
		return return_value.Detach();
	}

	The Detach() call returns a copy of the internal CByondValue while clearing
	out the ByondValue so it has nothing to clean up. The CByondValue copy
	still has to be cleaned up, which the caller (BYOND itself) will take care of
	on return.

	The args[] array is declared as ByondValue instead of CByondValue because
	it doesn't affect the call and makes the arguments easier to work wtih.
 */

class ByondValue: public CByondValue {
	public:
	ByondValue();
	ByondValue(ByondValueType type, u4c ref);
	ByondValue(float f);
	ByondValue(char const *str);
#ifdef _STRING_
	explicit ByondValue(std::string &str);
#endif
	ByondValue(CByondValue const &src);
	explicit ByondValue(ByondValue const &src);

	ByondValue &operator=(float f);
	ByondValue &operator=(char const *str);
	ByondValue &operator=(CByondValue const &src);
	bool operator==(CByondValue const &v) const;
	bool operator!=(CByondValue const &v) const;
	operator bool() const;

	void Clear();
	ByondValueType GetType() const;

	bool IsNull() const;
	bool IsNum() const;
	bool IsStr() const;
	bool IsList() const;
	bool IsTrue() const;
	bool IsType(char const *typestr) const;

	float GetNum() const;
	u4c GetRef() const;

	void SetNum(float f);
	void SetStr(char const *str);
	void SetRef(ByondValueType type, u4c ref);

	void IncRef();
	void DecRef();
	void DecTempRef();
	bool TestRef();

	ByondValue &Swap(CByondValue &other);

	bool ToString(char *buf, u4c *buflen) const;	// alias for Byond_ToString()
#ifdef _STRING_
	std::string ToString() const;
	void ToString(std::string &result) const;	// this version lets you pre-allocate string space
#endif
};


/*
	All of the C++-wrapped Byond_ functions throw ByondExtException on failure.

	Functions that return true/false in the C version and take a result pointer,
	now return a result and use the exception to indicate failure.

	An exception to this is routines that require the user to allocate memory.
	Those still return true/false, but the false value only indicates additional
	memory is needed. They throw ByondExtException on a true failure.
 */

ByondValue Byond_ReadVar(ByondValue const &loc, char const *varname);
ByondValue Byond_ReadVarByStrId(ByondValue const &loc, u4c varname);
void Byond_WriteVar(ByondValue const &loc, char const *varname, ByondValue val);
void Byond_WriteVarByStrId(ByondValue const &loc, u4c varname, ByondValue val);

ByondValue Byond_CreateList();
ByondValue Byond_CreateList(CByondValue const *list, u4c len);
#ifdef _VECTOR_
ByondValue Byond_CreateList(std::vector<CByondValue> const &list);
#endif

bool Byond_ReadList(ByondValue const &loc, CByondValue *list, u4c *len);
void Byond_WriteList(ByondValue const &loc, CByondValue const *list, u4c len);
bool Byond_ReadListAssoc(ByondValue const &loc, CByondValue *list, u4c *len);
#ifdef _VECTOR_
void Byond_ReadList(ByondValue const &loc, std::vector<CByondValue> &list);
void Byond_WriteList(ByondValue const &loc, std::vector<CByondValue> const &list);
void Byond_ReadListAssoc(ByondValue const &loc, std::vector<CByondValue> &list);
#endif

ByondValue Byond_ReadListIndex(ByondValue const &loc, ByondValue const &idx);
void Byond_WriteListIndex(ByondValue const &loc, ByondValue const &idx, ByondValue const &val);

ByondValue Byond_ReadPointer(ByondValue const &ptr);
void Byond_WritePointer(ByondValue const &ptr, ByondValue val);

ByondValue Byond_CallProc(ByondValue const &src, char const *name, CByondValue const *arg, u4c arg_count);
ByondValue Byond_CallProcByStrId(ByondValue const &src, u4c name, CByondValue const *arg, u4c arg_count);

ByondValue Byond_CallGlobalProc(char const *name, CByondValue const *arg, u4c arg_count);
ByondValue Byond_CallGlobalProcByStrId(u4c name, CByondValue const *arg, u4c arg_count);

bool Byond_ToString(CByondValue const &src, char *buf, u4c *buflen);
#ifdef _STRING_
std::string Byond_ToString(CByondValue const &src);
void Byond_ToString(CByondValue const &src, std::string &result);	// this version allows you to pre-allocate space
#endif

bool Byond_Return(ByondValue const &waiting_proc, ByondValue const &retval);

bool Byond_Block(CByondXYZ const &corner1, CByondXYZ const &corner2, CByondValue *list, u4c *len);
#ifdef _VECTOR_
void Byond_Block(CByondXYZ const &corner1, CByondXYZ const &corner2, std::vector<CByondValue> &list);
#endif

bool ByondValue_IsType(ByondValue const &src, char const *typestr);

ByondValue Byond_Length(ByondValue const &src);
ByondValue Byond_Locate(ByondValue const &type);
ByondValue Byond_LocateIn(ByondValue const &type, ByondValue const &list);
ByondValue Byond_LocateXYZ(CByondXYZ const &xyz);
ByondValue Byond_New(ByondValue const &src, CByondValue const *arg, u4c arg_count);
ByondValue Byond_NewArglist(ByondValue const &src, ByondValue const &arglist);
u4c Byond_Refcount(ByondValue const &src);
CByondXYZ Byond_XYZ(ByondValue const &src);
CByondPixLoc Byond_PixLoc(ByondValue const &src);
CByondPixLoc Byond_BoundPixLoc(ByondValue const &src, u1c dir);

#endif
