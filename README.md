# AVPlayer-Render
### iOS - 自定义视频播放器 -- (1)
#### 背景需求
如何将视频添加上自定义的渲染效果，并显示？
#### 大致流程
1、解码视频
2、获取视频帧
3、渲染视频帧
4、显示渲染后的视频帧
5、编码视频帧，生成新的视频

#### 通过AVPlayer进行实时获取视频帧
##### 核心对象：AVPlayer，AVPlayerItemVideoOutput
AVPlayer：驱动播放用例的中心阶层，是用于管理媒体资产的回放和定时的控制器对象
这里AVPlayer，我制作简单的播放，暂停，seek。并且添加上AVPlayerItemVideoOutput做一个视频帧输出的工作。
创建一个播放器**AVPlayer**作为一个驱动
主要的核心工具是**AVPlayerItemVideoOutput**，这对象相当于一个视频解码工具，对它进行属性设置，可以获取视频中某一时刻的想要数据的*CVPixelBuffer*视频帧。
```
func copyPixelBuffer(forItemTime itemTime: CMTime, itemTimeForDisplay outItemTimeForDisplay: UnsafeMutablePointer<CMTime>?) -> CVPixelBuffer?
```
通过获取到的CVPixelBuffer，进行OPenGL自定义渲染显示。
***
如何获取视频帧，这里都比较简单，都是通过系统层去实现功能。
主要注意的是：
1、AVPlayerItemVideoOutput的获取的数据格式定义，根据**需求设置RGBA还是YUV420的数据**。

2、AVPlayer使用seek时候，使用**精度比较高的方法**，提高在seek时候的画面流畅度

3、获取的CVPixelBuffer**在Swift语言，不需要手动释放**。在OC上需要调用手动释放
