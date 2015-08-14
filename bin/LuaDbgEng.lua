-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
package.cpath = package.cpath..';E:/GitHub/LuaDbgEng/Debug/?.dll;E:/GitHub/NonGUI/Debug/?.dll'
--
local _U, Eng = {}
local Eng = require 'LuaDbgEng' --Core lib
local Ui  = require 'NonUI'
--LuaDbgEng lib
LuaDbgEng = {} 
setmetatable(LuaDbgEng, {__index = Eng})
--Get Constant table
local Const = LuaDbgEng.GetConstTable()     --Constant table
local function ReverseConstant(cotxxx)
    if Const[cotxxx] then return Const[cotxxx] end
    Const[cotxxx] = {}
    for k,v in pairs(Const) do
        if k:find('^'..cotxxx) then
            Const[cotxxx][v] = k
        end
    end
    return Const[cotxxx]
end

--Debugger Object
_D = {}  local Dbg = _D

Dbg.Client = Eng.DebugCreate()
Dbg.Ctrl = Dbg.Client:QueryControl()
Dbg.Sym = Dbg.Client:QuerySymbols()
Dbg.Reg = Dbg.Client:QueryRegisters()
Dbg.DatSpc = Dbg.Client:QueryDataSpaces()
Dbg.SysObj = Dbg.Client:QuerySystemObjects()

--print(Dbg.Client , Dbg.Ctrl , Dbg.Sym , Dbg.Reg , Dbg.DatSpc , Dbg.SysObj)
assert(Dbg.Client and Dbg.Ctrl and Dbg.Sym
    and Dbg.Reg and Dbg.DatSpc and Dbg.SysObj)

--Some function in LuaDbgEng
local function getuservalue(ud)
    assert(type(ud)=="userdata", "getuservalue arg #1 must userdata")
    return _U[ud]
end
local function setuservalue(ud, value)
    assert(type(ud)=="userdata", "setuservalue arg #1 must userdata")
    _U[ud] = value
end
setmetatable(Dbg, {__index = function(t, k)
    local v = rawget(Dbg, k) if v then return v end
    v = LuaDbgEng[k] if v then return v end
    for lk, lv in pairs(Dbg) do if type(lv)=='userdata' and lv[k] then
        return function(...) return lv[k](lv, ...) end
    end end
    return nil
end})
--Some functions in the Debugger Object to simple use
function Dbg.SetEventCallback(t)
    return Dbg.Client:SetEventCallbacks(LuaDbgEng.NewEventCB(t))
end
function Dbg.SetOutputCallback(f)
    return Dbg.Client:SetOutputCallbacks(LuaDbgEng.NewOutputCB(f))
end
function Dbg.SetInputCallback(f)
    return Dbg.Client:SetInputCallbacks(LuaDbgEng.NewInputCB(f))
end

--Some Settings
Dbg.Ctrl:AddEngineOptions(Const.DEBUG_ENGOPT_INITIAL_BREAK |
    Const.DEBUG_ENGOPT_INITIAL_MODULE_BREAK | Const.DEBUG_ENGOPT_FINAL_BREAK)
Dbg.Sym:AppendSymbolPath [[D:\symbolslocal;srv*D:\symbolslocal*http://msdl.microsoft.com/download/symbols]]
ReverseConstant 'DEBUG_STATUS'

local OnBreak = {}
OnBreak[1] = function()
    print(Dbg.Sym:GetSymbolPath())
    io.read()
    print(Dbg.Sym:GetTypeId(0x400000, '_IMAGE_DOS_HEADER') or Eng.GetLastError())
    io.read()
end

local function BeginWaitEvent()
local nBreak = 0
dofile 'startup.lua'
while Dbg.Ctrl:WaitForEvent() do
    nBreak = nBreak + 1
    local func = OnBreak[nBreak]
    if func then pcall(func) end
    Dbg.Ctrl:OutputCurrentState()
    --print('Waited for event:',  Eng.GetLastError())
    repeat 
        print(Dbg.GetPromptText())
        local cmd = io.read()
        Dbg.Ctrl:Execute(cmd)
        cmd = ''
    until Dbg.GetExecutionStatus() ~= Const.DEBUG_STATUS_BREAK
    print(Eng.GetLastError())
end end

---[[
local wait = systhread.create(BeginWaitEvent)
wait:resume(BeginWaitEvent)

Ui.BeginUI()

--]]
