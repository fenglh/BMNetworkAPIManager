#### 2.2.4
1. 修复BMAPICalledProxy.m内存泄漏
2. 优化BMLogger日志等级划分

兼容性：BMNetworkLogLevel 枚举类型不兼容以前版本，需求在BMNetWrokConfigure重新配置一下函数。（否则编译报错）

```
- (BMNetworkLogLevel)networkLogLevel
{
return BMNetworkLogLevelUnLog ;
}


```
