//
//  ViewController.swift
//  PhotoSearcher
//
//  Created by Борис Глухоедов on 22/05/2019.
//  Copyright © 2019 glukhoedov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        
        searchImage(text: "panda")
        textField.becomeFirstResponder()
        imageView.layer.masksToBounds = true
    }
    
    func convert(farm: Int, server: String, photoId: String, secret: String) -> URL? {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoId)_\(secret)_c.jpg")
    }
    
    func showLoader(show: Bool) {
        DispatchQueue.main.async {
            if show {
                self.imageView.image = nil
                self.loader.startAnimating()
            }
            else {
                self.loader.stopAnimating()
            }
        }
    }
    
    func showError(text: String) {
        showLoader(show: false)
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(ok)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    // https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=1b21d114e4881afb1db2a4ab1a2b1ad3&format=json&nojsoncallback=1
    
    func searchImage(text: String) {
        showLoader(show: true)
        
        let base = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
        let key = "&api_key=1b21d114e4881afb1db2a4ab1a2b1ad3"
        let format = "&format=json&nojsoncallback=1"
        
        let formattedText = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let textToSearch = "&text=\(formattedText)"
        let sort = "&sort=relevance"
        
        let searchUrl = base + key + format + textToSearch + sort
        
        let url = URL(string: searchUrl)!
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            
            guard let jsonData = data else {
                self.showError(text: "Нет данных")
                return
            }
            guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                return
            }
            
            guard let photos = json["photos"] as? [String: Any] else {
                return
            }
            
            guard let photosArray = photos["photo"] as? [Any] else {
                return
            }
            
            guard photosArray.count > 0 else {
                self.showError(text: "error")
                return
            }
            
            guard let firstPhoto = photosArray[0] as? [String: Any] else {
                return
            }
            
            let farm = firstPhoto["farm"] as! Int
            let id = firstPhoto["id"] as! String
            let secret = firstPhoto["secret"] as! String
            let server = firstPhoto["server"] as! String
            
            let picUrl = self.convert(farm: farm, server: server, photoId: id, secret: secret)
            
            URLSession.shared.dataTask(with: picUrl!, completionHandler: { (data, _, _) in
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data!)
                }
                self.showLoader(show: false)
            }).resume()
            
            }.resume()
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        searchImage(text: textField.text!)
        
        return true
    }
}





