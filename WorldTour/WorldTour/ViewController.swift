//
//  ViewController.swift
//  WorldTour
//
//  Created by Jo JANGHUI on 2018. 7. 20..
//  Copyright © 2018년 JhDAT. All rights reserved.
//

import CoreLocation
import UIKit
import MapKit

import Colorify

class ViewController: UIViewController {
    
    private let mapView = MKMapView()
    let mapViewCoverButton = UIButton()
    private let scrollView = UIScrollView()
    let localTempButton = UIButton()  //
    let aboutView = UIView()
    var imageViews: [UIImageView] = []
    
    var isItOnAboutView = false
    
    var isImageHidden = false {
        didSet{
            scrollView.isScrollEnabled = !isImageHidden
        }
    }
    
    private let locationManager = CLLocationManager()   //위치정보 관할
    private var cityNum:CGFloat = 0
    
    var nowLat = 0.0
    var nowLon = 0.0
    
    var nowIndex = 0
    
    let myData = GetData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        mapView.showsUserLocation = true //시작할때 현 위치 보여줌
        
        NotificationCenter.default.addObserver(self, selector: #selector(localDownloadComplete), name: .localComplete, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(downloadComplete), name: .complete, object: nil)
        
        
        aboutView.center = view.center
        aboutView.backgroundColor = Colorify.Amber
        mapViewCoverButton.addSubview(aboutView)
    }
    
    @objc func localDownloadComplete() {
        print(LocalCitynames.shared.localCityname)
        if LocalCitynames.shared.localCityname != [:] {
            let allOfCities:[String:[Double]] = LocalCitynames.shared.localCityname
            let cityNameKeys:[String] = Array(allOfCities.keys)
            let localTemp = Int(LocalCitynames.shared.localCityname[cityNameKeys[0]]![0])
            
            localTempButton.frame.size = CGSize(width: view.frame.width, height: 50)
            localTempButton.frame.origin.y = -20
            localTempButton.center.x = view.center.x
            localTempButton.contentVerticalAlignment = .center
            localTempButton.titleLabel?.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 40)
            if localTemp >= 30 {
                localTempButton.setTitleColor(Colorify.Red, for: .normal)
            } else if  20 <= localTemp, localTemp < 30 {
                localTempButton.setTitleColor(Colorify.DeepOrange, for: .normal)
            } else {
                localTempButton.setTitleColor(Colorify.Cyan, for: .normal)
            }
            localTempButton.setTitle(String(localTemp), for: .normal)
            localTempButton.addTarget(self, action: #selector(tapLocalTemp(_:)), for: .touchUpInside)
            mapViewCoverButton.addSubview(localTempButton)
        }
    }
    
    @objc func downloadComplete() {
        DispatchQueue.main.async { [weak self] in
            var allOfCities:[String:[Double]] = Citynames.shared.cityname //도시의 모든 정보
            let cityNameKeys:[String] = Array(allOfCities.keys)
            
            self?.cityNum = CGFloat(Citynames.shared.cityname.count)
            self?.checkLocation()
            
            self?.setMapView()
            self?.setScrollView()
            self?.addPin()
            self?.moveToPoint(lat: Double(allOfCities[cityNameKeys[0]]![5]), lon: Double(allOfCities[cityNameKeys[0]]![4]))
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setMapView() {
        mapView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height) //뷰의 비율 수정할 때 사용
        
        mapViewCoverButton.frame = mapView.frame
        mapViewCoverButton.backgroundColor = UIColor(white: 1, alpha: 0.4)
        
        mapViewCoverButton.addTarget(self, action: #selector(tapMap(_:)), for: .touchUpInside)
        view.addSubview(mapView)
        view.addSubview(mapViewCoverButton)
    }
    
    private func setScrollView() {
        let frameWidth = view.frame.width
        scrollView.frame.size = CGSize(width: frameWidth, height: frameWidth)
        scrollView.center.x = view.center.x
        scrollView.center.y = view.center.y
        scrollView.showsHorizontalScrollIndicator = false
        for index in 0..<Int(cityNum) {
            addItems(index: index)
        }
        view.addSubview(scrollView)
        
        scrollView.contentSize = CGSize(width: frameWidth * cityNum, height: frameWidth)
        scrollView.isPagingEnabled = true
    }
    
    private func addItems(index: Int) {
        //데이터 정리
        var allOfCities:[String:[Double]] = Citynames.shared.cityname //도시의 모든 정보
        let cityNameKeys:[String] = Array(allOfCities.keys) //도시이름 배열
        let nowCityName:String = cityNameKeys[index]    //현재 도시 이름
        let nowCityData = allOfCities[nowCityName]!     //현재 도시 데이터
        
        //이미지뷰를 올릴 뷰
        let viewUnderImage = UIView(frame: CGRect(origin: CGPoint(x: scrollView.frame.width * CGFloat(index), y: 0), size: scrollView.frame.size))
        
        //이미지 뷰
        let cityImageView = UIImageView()
        cityImageView.isUserInteractionEnabled = true
        cityImageView.image = UIImage(named: nowCityName)
        cityImageView.frame.size = CGSize(width: viewUnderImage.frame.width - 20, height: viewUnderImage.frame.width - 20)
        cityImageView.frame.origin = CGPoint(x: 10, y: 10)
        cityImageView.contentMode = .scaleAspectFill
        
        //이미지 동그랗게
        cityImageView.layer.cornerRadius = cityImageView.frame.width/2
        cityImageView.layer.masksToBounds = true
        imageViews.append(cityImageView)
        
        //이미지 뷰 색 보정
        let imageColorView = UIView()
        imageColorView.frame = cityImageView.frame
        imageColorView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        imageColorView.layer.cornerRadius = cityImageView.frame.width/2
        imageColorView.layer.masksToBounds = true
        
        //이미지 위의 온도 등등
        //도시이름
        let cityName = UILabel()
        cityName.text = nowCityName
        cityName.textColor = .white
        cityName.frame.size = CGSize(width: cityImageView.frame.width/3 * 2, height: cityImageView.frame.width/3 * 2)
        cityName.center.x = cityImageView.center.x
        cityName.center.y = cityImageView.center.y - 30
        cityName.textAlignment = .center
        cityName.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 60)
        cityName.adjustsFontSizeToFitWidth = true
        
        //온도 수
        let tempLabel = UILabel()
        tempLabel.text = String(Int(nowCityData[0]))
        tempLabel.textColor = .white
        tempLabel.frame.size = CGSize(width: cityImageView.frame.width/2, height: cityImageView.frame.width/2)
        tempLabel.center.x = cityImageView.center.x - 25
        tempLabel.center.y = cityImageView.center.y + 100
        tempLabel.textAlignment = .center
        tempLabel.font = UIFont(name: "Hiragino Maru Gothic ProN", size: 40)
        
        //온도 이미지
        let celsiusImageView = UIImageView()
        celsiusImageView.frame.size = CGSize(width: 35, height: 35)
        celsiusImageView.center.x = cityImageView.center.x + 25
        celsiusImageView.center.y = tempLabel.center.y
        celsiusImageView.image = UIImage(named: "celsius")
        
        //이미지 뷰를 위한 버튼
        let cityImageButton = UIButton()
        cityImageButton.frame = cityImageView.frame
        cityImageButton.backgroundColor = UIColor(white: 0, alpha: 0)
        cityImageButton.layer.cornerRadius = cityImageView.frame.width/2
        cityImageButton.layer.masksToBounds = true
        cityImageButton.addTarget(self, action: #selector(tapImage(_:)), for: .touchUpInside)
        
        //뷰 올리기
        scrollView.addSubview(viewUnderImage)
        viewUnderImage.addSubview(cityImageView)
        viewUnderImage.addSubview(imageColorView)
        viewUnderImage.addSubview(tempLabel)
        viewUnderImage.addSubview(cityName)
        viewUnderImage.addSubview(celsiusImageView)
        viewUnderImage.addSubview(cityImageButton)
    }
    
    
    //현위치 체크
    private func checkLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() //권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
        nowLat = locationManager.location?.coordinate.latitude ?? 37.523984
        nowLon = locationManager.location?.coordinate.longitude ?? 126.980355
        
        //현재 위치로 이동
        moveToPoint(lat: nowLat, lon: nowLon)
        let center = CLLocationCoordinate2DMake(nowLat - 0.3, nowLon)
        let span = MKCoordinateSpanMake(1.0, 0.1)
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: true)
        myData.apiloadInName(lon: nowLon, lat: nowLat)
    }
    
    private func addPin() {
        let aaa = Array(Citynames.shared.cityname.keys)
        
        for index in 0..<aaa.count {
            let myPin = MKPointAnnotation()
            myPin.coordinate = CLLocationCoordinate2D(latitude: Citynames.shared.cityname[aaa[index]]![5], longitude: Double(Citynames.shared.cityname[aaa[index]]![4]))
            myPin.title = aaa[index]
            mapView.addAnnotation(myPin)
        }
    }
    
    private func moveToPoint(lat: Double, lon: Double) {
        let center = CLLocationCoordinate2DMake(lat - 0.3, lon)
        let span = MKCoordinateSpanMake(1.0, 0.1)
        let region = MKCoordinateRegionMake(center, span)
        mapView.setRegion(region, animated: true)
    }
    
    private func hideImage(lat: Double, lon: Double) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.mapViewCoverButton.isHidden = true
            self?.scrollView.center = CGPoint(x: self!.view.frame.minX - 130, y: self!.view.center.y )
            self?.moveToPoint(lat: lat, lon: lon) //이미지뷰에 가렸던 지도떄문에 조금 아래로 이동
        }
        isImageHidden = true
        if isItOnAboutView {
            UIView.animate(withDuration: 0.3) {
                self.aboutView.frame.origin = CGPoint(x: self.view.center.x, y: self.view.center.y)
                self.aboutView.frame.size = CGSize.zero
            }
        }
        isItOnAboutView = false
        
    }
    
    @objc private func tapImage(_ sender: UIButton) {
        let aaa = Array(Citynames.shared.cityname.keys)
        if isImageHidden {
            UIView.animate(withDuration: 0.5) {
                self.mapViewCoverButton.isHidden = false
                self.scrollView.center = self.view.center
                self.moveToPoint(lat: Double(Citynames.shared.cityname[aaa[self.nowIndex]]![5]), lon: Double(Citynames.shared.cityname[aaa[self.nowIndex]]![4]))   //이미지뷰에 가렸던 지도떄문에 조금 아래로 이동
            }
            isImageHidden = false
        } else {
            //상세 페이지로 넘어가기
            if isItOnAboutView {
                UIView.animate(withDuration: 0.3) {
                    self.aboutView.frame.origin = CGPoint(x: self.view.center.x, y: self.view.center.y)
                    self.aboutView.frame.size = CGSize.zero
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.aboutView.frame = CGRect(x: 0, y: self.view.center.y, width: self.view.frame.width, height: self.view.frame.height/2)
                }
            }
            
            isItOnAboutView = !isItOnAboutView
        }
    }
    //지도 터치
    @objc private func tapMap(_ sender: UIButton) {
        let aaa = Array(Citynames.shared.cityname.keys)
        hideImage(lat: Double(Citynames.shared.cityname[aaa[self.nowIndex]]![5]) + 0.3, lon: Double(Citynames.shared.cityname[aaa[self.nowIndex]]![4]))
    }
    
    @objc private func tapLocalTemp(_ sender: UIButton) {
        moveToPoint(lat: nowLat, lon: nowLon)
        hideImage(lat: nowLat, lon: nowLon)
        localTempButton.frame.origin.y = -20
    }
    
    @IBAction func swipeDown(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.localTempButton.frame.origin.y = 40
        }
    }
    @IBAction func swipeUp(_ sender: UISwipeGestureRecognizer) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.localTempButton.frame.origin.y = -20
        }
    }
    
}

extension ViewController: UIScrollViewDelegate {
    //페이지 이동될때마다 실행
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let aaa = Array(Citynames.shared.cityname.keys)
        
        let pageNum = Int(scrollView.contentOffset.x / scrollView.frame.width)
        print(pageNum)
        
        moveToPoint(lat: Double(Citynames.shared.cityname[aaa[pageNum]]![5]), lon: Double(Citynames.shared.cityname[aaa[pageNum]]![4]))
        
        nowIndex = pageNum
        
        if isItOnAboutView {
            UIView.animate(withDuration: 0.3) {
                self.aboutView.frame.origin = CGPoint(x: self.view.center.x, y: self.view.center.y)
                self.aboutView.frame.size = CGSize.zero
            }
        }
        isItOnAboutView = false
    }
}

extension ViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        //위치가 업데이트될때마다
//
//        if let coor = manager.location?.coordinate{
//            print("latitude" + String(coor.latitude) + "/ longitude" + String(coor.longitude))
//        }
//    }
}
