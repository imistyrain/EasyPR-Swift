# EasyPR-Swift ios端车牌识别

EasyPR-Swift是[EasyPR](https://github.com/liuruoze/EasyPR)的Swift实现，[EasyPR-iOS](https://github.com/zhoushiwei/EasyPR-iOS)中实现了EasyPR的OC版，但是其版本是基于1.3的, 与最新的1.6版还有不小的差距。

整个工程从0开始搭起，一共用了不到一个星期的时间，期间遇到了很多问题，比如[如何链接opencv库](https://blog.csdn.net/minstyrain/article/details/97531797)，[如何实时预览](https://blog.csdn.net/minstyrain/article/details/97612637)，[如何获取资源路径](https://www.jianshu.com/p/a3e776af4772)，[如何添加中文支持](https://blog.csdn.net/minstyrain/article/details/97654158)等，我都一一记录下来，并提供可复现的代码.

由于opencv2.framework有200多M，不适合放在github上，请按照[swift opencv开发](https://blog.csdn.net/minstyrain/article/details/97531797)的方法正确配置opencv库后即可编译运行。

其在IphoneX上运行需要大约50ms，基本能够满足实时处理的需要.

![](result.png)

## 参考：

* [EasyPR-iOS](https://github.com/zhoushiwei/EasyPR-iOS)

* [swift opencv开发](https://blog.csdn.net/minstyrain/article/details/97531797)

* [iOS swift 摄像头预览并用opencv处理](https://blog.csdn.net/minstyrain/article/details/97612637)

* [ios opencv添加中文支持](https://blog.csdn.net/minstyrain/article/details/97654158)

* [EasyPR安卓版](https://github.com/imistyrain/EasyPR4Android)