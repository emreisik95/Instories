//
//  StoryService.swift
//  Instories
//
//  Created by Vladyslav Yakovlev on 1/6/19.
//  Copyright © 2019 Vladyslav Yakovlev. All rights reserved.
//

import Foundation

final class StoryService {
    
    static func getHikayes(for user: User, completion: @escaping ([Story]) -> ()) {
        var previewUrl = [URL]()
        let storyPreviewString = "https://api.story.sybeta.tech/story/\(user.id)"
        
        guard let preview = storyPreviewString.url else {
            return completion([])
        }
        
        URLSession.shared.dataTask(with: preview) { dataa, responsee, errror in
            guard let dataaa = dataa, errror == nil else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            print("işledi")
            guard let json = (try? JSONSerialization.jsonObject(with: dataaa)) as? Json else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            guard let dataJson = json["data"] as? Json, let storiesJson = dataJson["stories"] as? [Json] else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            
            for storyJson in storiesJson {
                guard let imageUrlStr = storyJson["preview"] as? String, let imageUrl = imageUrlStr.url, let timestamp = storyJson["timestamp"] as? Int else {
                    return DispatchQueue.main.async {
                        completion([])
                    }
                }
                print(imageUrl)
                previewUrl.append(imageUrl)
            }

        
        let urlString = "http://storyviewer-env.rg3cqxriqr.us-east-2.elasticbeanstalk.com/?kullanici=\(user.username)"
        guard let url = urlString.url else {
            return completion([])
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? Json else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            var stories = [Story]()
            var i = 0
            print("işleme \(previewUrl)")
            for storyJson in json["icerik"] as! [String] {
                if storyJson.contains("mp4"){
                    let story = Story(imageUrl: previewUrl[i], timestamp: 1, videoUrl: URL(string: storyJson))
                    stories.append(story)
                }else{
                    let story = Story(imageUrl: URL(string: storyJson)!, timestamp: 1, videoUrl: nil)
                    stories.append(story)
                }
                i+=1 
            }
            DispatchQueue.main.async {
                completion(stories)
            }
            }.resume()
        }.resume()
    }
    
 /*   static func getStories(for user: User, completion: @escaping ([Story]) -> ()) {
        let urlString = "https://api.story.sybeta.tech/story/\(user.id)"
        
        guard let url = urlString.url else {
            return completion([])
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? Json else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            guard let dataJson = json["data"] as? Json, let storiesJson = dataJson["stories"] as? [Json] else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            var stories = [Story]()
            
            for storyJson in storiesJson {
                guard let imageUrlStr = storyJson["preview"] as? String, let imageUrl = imageUrlStr.url, let timestamp = storyJson["timestamp"] as? Int else {
                    return DispatchQueue.main.async {
                        completion([])
                    }
                }
                
                var videoUrl: URL?
                
                if let videoUrlStr = storyJson["video"] as? String {
                    videoUrl = videoUrlStr.url
                }
                
                let story = Story(imageUrl: imageUrl, timestamp: timestamp, videoUrl: videoUrl)
                stories.append(story)
            }
            
            DispatchQueue.main.async {
                completion(stories)
            }
            
        }.resume()
    }
    
    static func getStories2(for user: User, completion: @escaping ([Story]) -> ()) {
        let urlString = "https://api.storiesig.com/stories/\(user.username)/"
        
        guard let url = urlString.url else {
            return completion([])
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            guard let json = (try? JSONSerialization.jsonObject(with: data)) as? Json else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            guard let itemsJson = json["items"] as? [Json] else {
                return DispatchQueue.main.async {
                    completion([])
                }
            }
            
            var stories = [Story]()
            
            for itemJson in itemsJson {
                guard let imageVersionsJson = itemJson["image_versions2"] as? Json, let candidatesJson = imageVersionsJson["candidates"] as? [Json] else {
                    return DispatchQueue.main.async {
                        completion([])
                    }
                }
                
                guard let imageJson = candidatesJson.first, let imageUrlStr = imageJson["url"] as? String, let imageUrl = imageUrlStr.url else {
                    return DispatchQueue.main.async {
                        completion([])
                    }
                }
                
                guard let timestamp = itemJson["taken_at"] as? Int else {
                    return DispatchQueue.main.async {
                        completion([])
                    }
                }
                
                let story = Story(imageUrl: imageUrl, timestamp: timestamp, videoUrl: nil)
                stories.append(story)
            }
            
            DispatchQueue.main.async {
                completion(stories)
            }
            
        }.resume()
    }*/
}
