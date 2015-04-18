//ADDED BY LUZHLON	(All this file)
#include <Windows.h> 
#include "lua.h"

#include "lauxlib.h"
#include "lualib.h"

#include "lstate.h"

#define TNAMESTR_SYSTHREAD "g_utype_systhread"// userdata type name

extern const luaL_Reg systhreadlib[];

typedef struct _SysThread
{
	lua_State *thread;
	int        ref;//在C注册表中的引用，防止被回收
	DWORD      id;
	HANDLE     handle;
}SysThread;
DWORD WINAPI ThreadProc(LPVOID lp)
{
	SysThread *st = (SysThread *)lp;
	int ntop = lua_gettop(st->thread);
	int err = lua_pcall(st->thread, ntop-1, 0, 0);
	if (err) printf("[Thread %x callback error] %s", st, lua_tostring(st->thread, -1));
	if (st->ref) luaL_unref(st->thread, LUA_REGISTRYINDEX, st->ref);
	return err;
}
static int luaB_newthread (lua_State *L) {
  luaL_checktype(L, 1, LUA_TFUNCTION);

  int nTop = lua_gettop(L);
  lua_State* newthr = lua_newthread(L);
  int ref = luaL_ref(L, LUA_REGISTRYINDEX);//放到C注册表中防止被回收
  lua_xmove(L, newthr, nTop);//把启动函数以及参数移到新的lua_State 中

  SysThread *st = (SysThread *)lua_newuserdata(L, sizeof(SysThread));
  st->ref = ref;
  st->thread = newthr;
  //创建系统线程
  if ((st->handle =
	  CreateThread(NULL, NULL, ThreadProc, st, CREATE_SUSPENDED, &st->id)))
  {
	  luaL_newmetatable(L, TNAMESTR_SYSTHREAD); //创建一个类型为 TNAMESTR_SYSTHREAD 的userdata
	  luaL_newlib(L, systhreadlib);
	  lua_setfield(L, -2, "__index");
	  lua_setmetatable(L, -2);
  }
  else //创建失败，返回false
	  if (!st->handle) { lua_pushboolean(L, 0); }

  return 1;
}
static int luaB_resumethread (lua_State *L) {
  SysThread *st = (SysThread *)luaL_checkudata(L, 1, TNAMESTR_SYSTHREAD);

  int count = ResumeThread(st->handle);
  if (count == -1) lua_pushboolean(L, 0);
  else lua_pushinteger(L, count);

  return 1;
}
static int luaB_suspendthread (lua_State *L) {
  SysThread *st = (SysThread *)luaL_checkudata(L, 1, TNAMESTR_SYSTHREAD);

  int count = SuspendThread(st->handle);
  if (count == -1) lua_pushboolean(L, 0);
  else lua_pushinteger(L, count);

  return 1;
}
static int luaB_terminatethread(lua_State *L) {
  SysThread *st = (SysThread *)luaL_checkudata(L, 1, TNAMESTR_SYSTHREAD);

  BOOL b = TerminateThread(st->handle, lua_isnoneornil(L, 2) ? 0 : luaL_checkinteger(L, 2));
  lua_pushboolean(L, b);
  luaL_unref(st->thread, LUA_REGISTRYINDEX, st->ref);  st->ref = 0;

  return 1;
}
static int luaB_waitthread(lua_State *L) {
  SysThread *st = (SysThread *)luaL_checkudata(L, 1, TNAMESTR_SYSTHREAD);

  WaitForSingleObject(st->handle,
	  lua_isnoneornil(L, 2) ? INFINITE : luaL_checkinteger(L, 2));

  return 0;
}
static int luaB_getthreadexitcode(lua_State *L) {
  SysThread *st = (SysThread *)luaL_checkudata(L, 1, TNAMESTR_SYSTHREAD);

  DWORD exitCode;
  BOOL b = GetExitCodeThread(st->handle, &exitCode);
  if (b)
	  lua_pushinteger(L, exitCode);
  else
  if (exitCode == STILL_ACTIVE)
	  lua_pushboolean(L, b);
  else
	  lua_pushnil(L);

  return 1;
}
static int luaB_getid(lua_State *L) {
  SysThread *st = (SysThread *)luaL_checkudata(L, 1, TNAMESTR_SYSTHREAD);

  lua_pushinteger(L, st->id);
  lua_pushinteger(L, st->handle);
  return 2;
}
static int luaB_threadsleep(lua_State *L) {
  Sleep(luaL_checkinteger(L, 1));
  return 0;
}

static const luaL_Reg systhreadlib[] = {
	{"create",luaB_newthread},
	{"resume",luaB_resumethread},
	{"suspend",luaB_suspendthread},
	{"terminate",luaB_terminatethread},
	{"wait",luaB_waitthread},
	{"exitcode",luaB_getthreadexitcode},
	{"getid",luaB_getid},
	{"sleep",luaB_threadsleep},
	{NULL,NULL}
};

int luaopen_systhread(lua_State *L) {
	luaL_newlib(L, systhreadlib);
	return 1;
}
