//
//  StoryVC.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 1/7/19.
//  Copyright © 2019 Vladyslav Yakovlev. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
@available(iOS 10.0, *)
final class StoryVC: UIViewController {
    
    var story: Story!
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let closeButton: RoundButton = {
        let button = RoundButton(type: .custom)
        button.setImage(UIImage(named: "CloseIcon"))
        button.backgroundColor = UIColor(white: 1, alpha: 0.7)
        button.setShadowOpacity(0.26)
        button.setShadowColor(.gray)
        button.setShadowRadius(12)
        return button
    }()
    
    private let downloadButton: RoundButton = {
        let button = RoundButton(x: UIScreen.main.bounds.width-85, y: UIScreen.main.bounds.height-160, w: 65, h: 65)
        button.setImage(UIImage(named: "DownloadIcon"))
        button.backgroundColor = UIColor(white: 1, alpha: 0.7)
        button.setShadowOpacity(0.26)
        button.setShadowColor(.gray)
        button.setShadowRadius(12)
        return button
    }()
    
    private var playerLayer: AVPlayerLayer?
    
    private var videoLooper: AVPlayerLooper?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(closeButtonTapped))
        gesture.direction = .down
        self.view.addGestureRecognizer(gesture)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        
        view.addSubview(imageView)
        view.addSubview(closeButton)
        view.addSubview(downloadButton)
        imageView.image = story.image
        
        scaleDownImageView()
        
        if let videoUrl = story.videoUrl {
            playerLayer = AVPlayerLayer()
            imageView.layer.addSublayer(playerLayer!)
            prepareForPlayingVideo(videoUrl)
            playVideo()
            downloadButton.addTarget(self, action: #selector(downloadVideo), for: .touchUpInside)
        }else{
        downloadButton.addTarget(self, action: #selector(downloadImage), for: .touchUpInside)
        }
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func downloadVideo() {
        DispatchQueue.global(qos: .background).async {
            if let url = self.story.videoUrl,
                let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            print("Video is saved!")
                        }
                    }
                }
            }
        }    }
    @objc private func downloadImage() {
            guard let selectedImage = story.image else {
                print("Image not found!")
                return
            }
            UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    func showAlertWith(title: String, message: String){
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    private func layoutViews() {
        imageView.frame = view.bounds
        playerLayer?.frame = imageView.bounds
        
        closeButton.frame.size = CGSize(width: 43, height: 43)
        closeButton.frame.origin.x = view.frame.width - closeButton.frame.width - 20
        closeButton.frame.origin.y = currentDevice == .iPhoneX ? 58 + UIProperties.iPhoneXTopInset : 20
    }
    
    func scaleUpImageView() {
        imageView.transform = .identity
    }
    
    func scaleDownImageView() {
        imageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
    
    private func prepareForPlayingVideo(_ videoUrl: URL) {
        let asset = AVAsset(url: videoUrl)
        let item = AVPlayerItem(asset: asset)
        
        let player = AVQueuePlayer(playerItem: item)
        if #available(iOS 10.0, *) {
            player.automaticallyWaitsToMinimizeStalling = false
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 10.0, *) {
            videoLooper = AVPlayerLooper(player: player, templateItem: item)
        } else {
            // Fallback on earlier versions
        }
        playerLayer!.player = player
    }
    
    private func playVideo() {
        playerLayer?.player?.play()
    }
}
