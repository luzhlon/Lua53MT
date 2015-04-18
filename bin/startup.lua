----------------------------------------------------------------------
----------------------Test code---------------------------------------
----------------------------------------------------------------------
d = _D

d.SetInputCallback(function(isStart, buffsize)
    print '----------------INPUT----------------'  
end)

d.SetOutputCallback(function(outp, text)
    io.write(text)
end)

d.Client:CreateProcess([[D:\BaiDuYun\Projects\VC6\Ñ¹Ëõ\Debug\Ñ¹Ëõ.exe]])

----------------------------------------------------------------------
----------------------------------------------------------------------
----------------------------------------------------------------------
--[[
dbg:SetEventCallback("LoadModule", function(t)
    --print('LoadModule:'..t["ImageName"], string.format("%x", t.BaseOffset))
    --[[
    local cmd = string.format("u %x", t.BaseOffset+250)
    dbg:Execute(cmd)
    --]]
    --[[
    local s, n = nil, t.BaseOffset + 512
    for i=1,10 do
        s, n = dbg:Disassemble(n)
        print(s)
        print(s:match("%w+%s+%w+%s+(%w+)%s+(%w+)%s+(%w+).*"))
    end
    --]]
    --
    --[[
    local r = dbg:GetOffset("CreateFile")
    if not r then return end
    if type(r)=="number" then print(string.format("%x", r)) return end
    for k,v in pairs(r) do print(k,v) end
    --return con.DEBUG_STATUS_GO_HANDLED
end)
--]]--
