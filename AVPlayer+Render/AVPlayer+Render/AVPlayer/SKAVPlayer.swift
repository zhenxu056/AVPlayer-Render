//
//  SKAVPlayer.swift
//  AVPlayer+Render
//
//  Created by Sunflower on 2020/4/26.
//  Copyright © 2020 Sunflower. All rights reserved.
//

import UIKit

import AVFoundation

enum SKVideoPlayerEventStatus {
    case Prepared
    case Finish
    case Close
    case Error
}

protocol SKAVPlayerDelegate : NSObjectProtocol {
    func onPlaye(player: SKAVPlayer, statu:SKVideoPlayerEventStatus)
}

class SKAVPlayer: NSObject {
    
    weak var delegate: SKAVPlayerDelegate?
    
    var videoURL:URL!
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var playing = false
    var videoFPS:Float = 30.0
    var durationTime:TimeInterval = 0.0
    var onPixelBuffer:CVPixelBuffer? {
        get {
            //获取当前视频帧
            let time = self.playerOutput.itemTime(forHostTime: CACurrentMediaTime())
            if self.playerOutput.hasNewPixelBuffer(forItemTime: time) {
                return self.playerOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil)
            } else {
                return nil
            }
        }
    }
    
    var playerOutput:AVPlayerItemVideoOutput = {
        // 根据需求获取相对于视频帧数据  通常选择RGBA数据,比较容易处理.系统默认是Y-UV数据
        let out = AVPlayerItemVideoOutput(pixelBufferAttributes: [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA])
        return out
    }()
    
    
    init(videoPath url:URL) {
        super.init()
        videoURL = url
        let urlAsset = AVURLAsset(url: videoURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey:true])
        //获取视频FPS
        let assetTrack = urlAsset.tracks(withMediaType: .video).first
        videoFPS = Float(assetTrack?.nominalFrameRate ?? 30)
        
        playerItem = AVPlayerItem(asset: urlAsset)
        playerItem?.add(playerOutput)
        
        player = AVPlayer(playerItem: playerItem)
        player?.isMuted = false
        
        addObserver()
    }
    
    func addObserver() {
        
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self, queue: OperationQueue.main) { _ in
            self.sendPlayerStauDelegate(videoStatu: .Finish)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let item = object as? AVPlayerItem {
                switch item.status {
                case .readyToPlay:
                    durationTime = CMTimeGetSeconds(item.duration)*1000
                    sendPlayerStauDelegate(videoStatu: .Prepared)
                default:
                    sendPlayerStauDelegate(videoStatu: .Error)
                }
            }
            
        }
    }
    
    func sendPlayerStauDelegate(videoStatu:SKVideoPlayerEventStatus) {
        if self.delegate != nil {
            self.delegate?.onPlaye(player: self, statu: videoStatu)
        }
    }

    public func getCurrentTime() -> Float {
        let time = CMTimeGetSeconds(player?.currentItem?.currentTime() ?? CMTimeMake(value: 0, timescale: 1000)) * 1000
        return Float(time)
        
    }
}

extension SKAVPlayer {
    func play() {
        if !playing {
            player?.play()
            playing = true
        }
    }
    
    func pause() {
        if playing {
            player?.pause()
            playing = false
        }
    }
    
    func seekTo(time:CMTime) {
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
