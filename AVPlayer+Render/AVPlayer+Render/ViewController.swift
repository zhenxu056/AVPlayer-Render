//
//  ViewController.swift
//  AVPlayer+Render
//
//  Created by Sunflower on 2020/4/26.
//  Copyright © 2020 Sunflower. All rights reserved.
//

import UIKit

import AVFoundation

class ViewController: UIViewController, SKAVPlayerDelegate {
    
    @IBOutlet weak var actionSlider: UISlider!
    
    lazy var player: SKAVPlayer = {
        let path = Bundle.main.path(forResource: "hahaha", ofType: "MP4")!
        let p = SKAVPlayer(videoPath: URL(fileURLWithPath: path))
        return p
    }()
    
    lazy var renderView:SKPixelBufferDisplayView = {
        let view = SKPixelBufferDisplayView(frame: self.view.bounds)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.insertSubview(renderView, at: 0)
        
        actionSlider.minimumValue = 0.0
        
        player.delegate = self
        
        //根据视频的FPS,添加定时器,作为获取视频帧驱动
        let disLink = Timer(timeInterval: TimeInterval(1.0/player.videoFPS), target: self, selector: #selector(renderFrame), userInfo: nil, repeats: true)
        RunLoop.current.add(disLink, forMode: .common)
        
    }

    @objc func renderFrame() {
        //获取单前视频帧
        if let pix = player.onPixelBuffer {
            let time = player.getCurrentTime()
            //显示单前帧
            renderView.display(pix)
            
            if player.playing {
                actionSlider.setValue(time, animated: true)
            }
        }
        
    }


    func onPlaye(player: SKAVPlayer, statu: SKVideoPlayerEventStatus) {
        if statu == .Prepared {
            actionSlider.maximumValue = Float(player.durationTime)
            player.play()
        } else if statu == .Finish {
            player.seekTo(time: CMTimeMake(value: 0, timescale: 1000))
            player.play()
        }
    }
    
    
    @objc func deleteButtonAction(sender:UIButton) {
        
    }
    @IBAction func actionButton(_ sender: UIButton) {
        sender.isSelected = sender.isSelected ? false:true
        if sender.isSelected {
            player.play()
        } else {
            player.pause()
        }
    }
    
    @IBAction func seekSelectAction(_ sender: UISlider) {
        player.pause()
        player.seekTo(time: CMTime(value: CMTimeValue(sender.value), timescale: 1000))
        if let pix = player.onPixelBuffer {
            //显示单前帧
            renderView.display(pix)
        }
    }
}

