local function ff1(n)
    for i = 1, n do
        print('Thread 1 --> \t'..i)
    end
end
local function ff2(n)
    for i = 1, n do
        print('Thread 2 --> \t'..i)
    end
end
local function ff3(n)
    for i = 1, n do
        print('Thread 3 --> \t'+i)--Error code
    end
end
local function ff4(n)
    for i = 1, n do
        print('Thread 4 --> \t'..i)
        --systhread.sleep(5)
    end
end

local st1 = systhread.create(ff1, 4)
local st2 = systhread.create(ff2, 6)
local st3 = systhread.create(ff3, 8)

st1:resume()
st2:resume()
st3:resume()

st1:wait() print('Thread 1 exitcode : '..st1:exitcode())
st2:wait() print('Thread 2 exitcode : '..st2:exitcode())
st3:wait() print('Thread 3 exitcode : '..st3:exitcode())

print ''
print (st1:getid())
print 'Create st4 ...'
local st4 = systhread.create(ff4, 10)
print 'Resume st4 ...'
st4:resume()
systhread.sleep(5)
print 'Suspend st4 ...'
st4:suspend()
print 'Resume st4 ...'
st4:resume()
