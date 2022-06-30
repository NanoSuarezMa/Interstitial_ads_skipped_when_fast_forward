//
//  ViewController.swift
//  SkipForwardAVPlayerViewController
//
//  Created by Fernando Suarez on 24.04.20.
//  Copyright © 2020 Fernando Suarez. All rights reserved.
//

import UIKit
import AVKit


final class ViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {
    var playerItem: PlayerItemFastForwardCustom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        isSkipForwardEnabled = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        play(stream: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!)
    }
    
    
    // MARK: AVPlayerViewControllerDelegate

    func playerViewController(_ playerViewController: AVPlayerViewController, timeToSeekAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) -> CMTime {
        
        // Only evaluate if the user performed a forward seek.
        guard  oldTime < targetTime else {
            return targetTime
        }
        
        // Define the time range of the user's seek operation.
        let seekRange = CMTimeRange(start: oldTime, end: targetTime)
        
        // Iterate over the defined interstitial time ranges.
        for interstitialRange in playerItem?.interstitialTimeRanges ?? [] {
            // If the current interstitial content is contained within the
            // user's seek range, return the interstitial content's start time.
            if seekRange.containsTimeRange(interstitialRange.timeRange) {
                return interstitialRange.timeRange.start
            }
        }
        return targetTime
        
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willPresent interstitial: AVInterstitialTimeRange) {
        player?.play()
        playerViewController.requiresLinearPlayback = true
        playerItem?.fastForwardEnabled = false
        playerViewController.isSkipForwardEnabled = false
    }
    
    func playerViewController(_ playerViewController: AVPlayerViewController, didPresent interstitial: AVInterstitialTimeRange) {
        playerViewController.requiresLinearPlayback = false
        playerItem?.fastForwardEnabled = true
        playerViewController.isSkipForwardEnabled = true
    }
    
    // MARK: - Private
    
    private func play(stream: URL) {
        player = AVPlayer()
        let asset = AVAsset(url: stream)
        playerItem = PlayerItemFastForwardCustom(asset: asset, automaticallyLoadedAssetKeys: nil)
        playerItem?.fastForwardEnabled = true
        playerItem?.interstitialTimeRanges = makeInterstitialTimeRanges()
        player?.replaceCurrentItem(with: playerItem)
        player?.play()
    }
    
    private func makeInterstitialTimeRanges() -> [AVInterstitialTimeRange] {
        // Present a 10-second content warning at the beginning of the video.
        let timeRange1 = CMTimeRange(start: CMTime(value: 150, timescale: 1),
                                         duration: CMTime(value: 10, timescale: 1))

            // Present 1 minute of advertisements 10 minutes into the video.
        let timeRange2 = CMTimeRange(start: CMTime(value: 300, timescale: 1),
                                         duration: CMTime(value: 60, timescale: 1))

            // Return an array of AVInterstitialTimeRange objects.
            return [
                AVInterstitialTimeRange(timeRange: timeRange1),
                AVInterstitialTimeRange(timeRange: timeRange2)
            ]
    }
}

class PlayerItemFastForwardCustom: AVPlayerItem {
    override var canPlayFastForward: Bool {
        return fastForwardEnabled
    }

    override var canPlaySlowForward: Bool {
        return fastForwardEnabled
    }
    
    var fastForwardEnabled: Bool = true
}
