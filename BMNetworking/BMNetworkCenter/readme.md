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
#### 3.0.0

1.  此版本动较大，本次改动增加接口实例对象的配置能力。BMNetworConfig 能配置的，接口都能配置。
2.  `- (NSString *)testBaseUrl;`  更改名字: `- (NSString *)baseUrlTest;`
3.  此版本最先使用的"月亮小店"App上
4.  历史项目接入，请测试接口是否存在异常
