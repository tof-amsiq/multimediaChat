//
//  GifKeyboardView.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 14/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import GiphyCoreSDK
import RxSwift
import RxCocoa
import UIKit

protocol GifPickerDelegate: class {
    func getLink(_ url: String?)
}

class GifKeyboardView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{

    weak var delegate: GifPickerDelegate?
    
    private var gifArray: [String] = []
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var contentView: UIView!
    
    let kCONTENT_XIB_NAME = "GifKeyboardView"
    
    let disposeBag = DisposeBag() // Bag of disposables to release them when view is being deallocated
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if self.subviews.count == 0 {
            commonInit()
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if self.subviews.count == 0 {
            commonInit()
        }
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        self.setup()
    }
    
    func setup(){
        // Do any additional setup after loading the view.
        GiphyCore.configure(apiKey: "NYpq6j1X5wXDZYYslFFsBmA8A2OF7nIk")
       
        
      
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.collectionView.layer.borderWidth = 1
        
        self.collectionView.layer.borderColor = UIColor(red:7/255, green:7/255, blue:7/255, alpha: 1).cgColor
        self.collectionView.register(UINib.init(nibName: "GifCell", bundle: nil), forCellWithReuseIdentifier: "GifCell")
       
        self.showDefaultGifs()
        
        self.textField
            .rx.text // Observable property thanks to RxCocoa
            .orEmpty // Make it non-optional
            .debounce(0.5, scheduler: MainScheduler.instance) // Wait 0.5 for changes.
            .distinctUntilChanged() // If they didn't occur, check if the new value is the same as old.
//            .filter { !$0.isEmpty } // If the new value is really new, filter for non-empty query.
            .subscribe(onNext: { [unowned self] query in // Here we subscribe to every new value, that is not empty (thanks to filter above).
                // We now do our "API Request" to find cities.
                // And reload table view data.
                if query.isEmpty{
                    self.showDefaultGifs()
                } else {
                    self.getGifArray(query: query)
                }
                
            })
            .disposed(by: disposeBag)
       

    }

    func getGifArray(query: String) {
        self.gifArray.removeAll()
        
        
        // Gif Search
        _ = GiphyCore.shared.search(query) { (response, error) in
            
            if (error as NSError?) != nil {
                // Do what you want with the error
            }
            
            if let response = response, let data = response.data, let pagination = response.pagination {
                print(response.meta)
                print(pagination)
                for result in data {
                    if let gifUrl = result.images?.original?.gifUrl {
                        self.gifArray.append(gifUrl)
                        
                    }
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            } else {
                print("No Results Found")
            }
        }
    }
    
    
    func showDefaultGifs() {
        self.gifArray.removeAll()
        _ = GiphyCore.shared.trending() { (response, error) in
            
            if (error as NSError?) != nil {
                // Do what you want with the error
            }
            
            if let response = response, let data = response.data, let pagination = response.pagination {
                print(response.meta)
                print(pagination)
                for result in data {
                    if let gifUrl = result.images?.original?.gifUrl {
                        self.gifArray.append(gifUrl)
                        
                    }
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            } else {
                print("No Results Found")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width/2, height: 125)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.gifArray.isEmpty {
            return 5
        } else {
            return self.gifArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GifCell", for: indexPath) as! GifCell
        
        if self.gifArray.isEmpty {
            cell.setup(gifURL: "")
        }else {
            let URL = self.gifArray[indexPath.row]
            cell.setup(gifURL: URL)
            //        self.gifLink = URL
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = self.gifArray[indexPath.row]
        delegate?.getLink(url)
        self.textField.text = ""
    }
}
