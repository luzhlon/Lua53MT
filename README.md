# 声明
源代码来自于Lua官方网站，经过我的简单修改，使Lua成为支持多线程的脚本

#使用
systhread.create(startFunc, ...) --创建一个系统线程
参数1(startFunc):
    系统线程的入口函数
参数(...):
    要传给函数的参数
返回值:
    成功，返回一个包含系统线程信息的userdata;失败，返回false.
注意：
    线程创建后处于挂起状态

systhread.resume(systhr) --恢复一个系统线程的执行
参数1(systhr):
    通过systhread.create 创建的系统线程(userdata).
返回值:
    成功，返回resume的次数;失败，返回false.
注意：
    NULL

systhread.suspend(systhr) --挂起一个线程
参数1(systhr):
    通过systhread.create 创建的系统线程(userdata).
返回值:
    成功，返回suspend的次数;失败，返回false.
注意：
    NULL

systhread.terminate(systhr) --终止一个线程
参数1(systhr):
    通过systhread.create 创建的系统线程(userdata).
返回值:
    成功，返回true;失败，返回false.
注意：
    NULL

systhread.wait(systhr, [millisec]) --等待一个线程执行结束
参数1(systhr):
    通过systhread.create 创建的系统线程(userdata).
参数2(millisec):
    等待的时间(毫秒);如果不指定，则为INFINITE (无穷大)
返回值:
    无返回值.
注意：
    NULL

systhread.exitcode(systhr) --等待一个线程执行结束
参数1(systhr):
    通过systhread.create 创建的系统线程(userdata).
返回值:
    成功，则返回线程的退出码(exitcode)
注意：
    失败，若线程还在运行，返回false;其它的情况，返回nil

systhread.getid(systhr) --获取一个系统线程的ID
参数1(systhr):
    通过systhread.create 创建的系统线程(userdata).
返回值:
    成功，则返回线程的ID
注意：
    NULL

systhread.sleep(millisec) --使所在线程休眠
参数1(millisec):
    等待的时间(毫秒)
返回值:
    无返回值.
注意：
    NULL

# 改动
在全局表中加入了systhread这个表，即所有操作'系统（抢先式）线程的功能都封装在了这个表里; 
所有的改动都在源代码中用 "//ADDED BY LUZHLON" 注释了.
