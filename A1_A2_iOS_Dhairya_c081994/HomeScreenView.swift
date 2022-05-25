//
//  HomeScreenView.swift
//  A1_A2_iOS_Dhairya_c081994
//
//  Created by dhairya bhavsar on 2022-05-25.
//

import UIKit
import MapKit
import CoreLocation

class HomeScreenView: UIViewController  {
    
    
    @IBOutlet var MPView: MKMapView!
    @IBOutlet weak var kmtxt: UILabel!
    @IBOutlet weak var NaviBar: UINavigationBar!
    
    
    var LocationHandler: CLLocationManager!
    
    var CTY : [MKMapItem] = []
    var Circle: MKPolygon? = nil
                                    
    let item = UINavigationItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MPView.delegate = self
        if (CLLocationManager.locationServicesEnabled())
        {
            LocationHandler = CLLocationManager()
            LocationHandler.delegate = self
            LocationHandler.desiredAccuracy = kCLLocationAccuracyBest
            LocationHandler.requestAlwaysAuthorization()
            LocationHandler.startUpdatingLocation()
        }
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(Taplong))
        self.MPView.addGestureRecognizer(longPressRecognizer)
        
        
        item.rightBarButtonItem = UIBarButtonItem(title: "Direction", style: .plain, target: self, action: #selector(addPhotosTapped))
        self.NaviBar.items = [item]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkRouteOption()
    }
    
    func checkRouteOption() {
        if CTY.count > 2 {
            self.NaviBar.items = [item]
        } else {
            self.NaviBar.items?.removeAll()
        }
    }
    
    @objc func addPhotosTapped() {
        if MPView.overlays.last != nil {
            self.MPView.removeOverlay(MPView.overlays.last!)
            Circle = nil
        }
        for i in 0..<CTY.count {
            if i == 0 {
                direction(source: LocationHandler.location!.coordinate, destination: CTY[i].placemark.coordinate, title: "A")
            } else if i == 1 {
                direction(source: CTY[i-1].placemark.coordinate, destination: CTY[i].placemark.coordinate, title: "B")
            } else if i == 2 {
                direction(source: CTY[i-1].placemark.coordinate, destination: CTY[i].placemark.coordinate, title: "C")
            }
        }
    }
    
    func displayDistance() {
        kmtxt.text = ""
        var latticur = LocationHandler.location?.coordinate.latitude
        var longcur = LocationHandler.location?.coordinate.longitude
        
        var str = ""
        for i in 0..<CTY.count {
            let dist = getpath(source: LocationHandler.location!.coordinate, destination: CTY[i].placemark.coordinate) / 1000.0
            var strAn = ""
            if i == 0 {
                strAn = "A"
            } else if i == 1 {
                strAn = "B"
            } else if i == 2 {
                strAn = "C"
            }
            str += "Current location to \(strAn) : \(distfrmt(value: dist)) \n "
        }
        str += " \n "
        for i in 0..<CTY.count {
//            if i == arrCity.count - 1 {
//
//            } else {
                var strAn = ""
                if i == 1 {
                    strAn = "A to B"
                    let dist = getpath(source: CTY[i].placemark.coordinate, destination: CTY[i-1].placemark.coordinate) / 1000.0
                    str += "\(strAn) : \(distfrmt(value: dist)) \n "
                } else if i == 2 {
                    strAn = "B to C"
                    let dist = getpath(source: CTY[i].placemark.coordinate, destination: CTY[i-1].placemark.coordinate) / 1000.0
                    str += "\(strAn) : \(distfrmt(value: dist)) \n "
                    
                    strAn = "C to A"
                    let dist1 = getpath(source: CTY[i].placemark.coordinate, destination: CTY[0].placemark.coordinate) / 1000.0
                    str += "\(strAn) : \(distfrmt(value: dist1))"
                }
            }
//        }
        
        kmtxt.text = str
    }
    
    func direction(source : CLLocationCoordinate2D, destination : CLLocationCoordinate2D, title : String) {
//        let sourceLocation = CLLocationCoordinate2D(latitude:39.173209 , longitude: -94.593933)
//        let destinationLocation = CLLocationCoordinate2D(latitude:38.643172 , longitude: -90.177429)
        
        let sourceLocation = source
        let destinationLocation = destination
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }
            
            //get route and assign to our route variable
            let route = directionResonse.routes[0]
            route.polyline.title = title
            //add rout to our mapview
            self.MPView.addOverlay(route.polyline, level: .aboveRoads)
            
            //setting rect of our mapview to fit the two locations
            let rect = route.polyline.boundingMapRect
            self.MPView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    func distfrmt(value : Double) -> String {
        return String(format: "%.2f km", value)
    }
    
    @objc func Taplong(sender: UILongPressGestureRecognizer) {
        print("longtapped")
        let alert = UIAlertController(title: "Pressed", message: "Add Place?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "CityAddView") as! CityAddView
            searchVC.MpVIew = self.MPView
            searchVC.delegate = self
            self.navigationController?.pushViewController(searchVC, animated: true)
          }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
          
          }))

        present(alert, animated: true, completion: nil)
    }
    
    func addPolygon() {
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        
        for i in 0..<CTY.count {
            points.append(CTY[i].placemark.coordinate)
        }
        
        let polygon = MKPolygon(coordinates: points, count: points.count)
        self.Circle = polygon
        MPView.addOverlay(polygon)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.tapCount == 1 {
                let touchLocation = touch.location(in: self.MPView)
                let locationCoordinate = MPView.convert(touchLocation, toCoordinateFrom: MPView)
                
                for polygon in MPView.overlays as! [MKPolygon] {
                    let renderer = MKPolygonRenderer(polygon: polygon)
                    let mapPoint = MKMapPoint(locationCoordinate)
                    let viewPoint = renderer.point(for: mapPoint)
                    if polygon.contain(coor: locationCoordinate) {
//                    if renderer.path.contains(viewPoint) {
                        print("With in range")
                        mlstn(location: locationCoordinate)
                    } else {
                        print("out side of range")
                    }
                }
            }
        }
        
        super.touchesEnded(touches, with: event)
    }
    
    func mlstn(location : CLLocationCoordinate2D) {
        var distary : [Double] = []
        for i in 0..<CTY.count {
            let dissst = getpath(source: location, destination: CTY[i].placemark.coordinate)
            distary.append(dissst)
        }
        let ss = distary.max { a, b in
            return a > b
        }
        var index = 0
        for i in 0..<distary.count {
            if ss == distary[i] {
                index = i
                break
            }
        }
        CTY.remove(at: index)
//        mapView.removeAnnotation(annotations[index])
        MPView.removeAnnotations(MPView.annotations)
        if MPView.overlays.last != nil {
            MPView.removeOverlay(MPView.overlays.last!)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.mrkr()
            self.checkRouteOption()
        }
        
    }
    
    func getpath(source : CLLocationCoordinate2D, destination : CLLocationCoordinate2D) ->  Double {
        let coordinate₀ = CLLocation(latitude: source.latitude, longitude: source.longitude)
        let coordinate₁ = CLLocation(latitude: destination.latitude, longitude: destination.longitude)

        let distanceInMeters = coordinate₀.distance(from: coordinate₁)
        return Double(distanceInMeters)
    }
    
    func mrkr() {
        var annotations = [MKAnnotation]()
        for i in 0..<CTY.count {
            let annotation = MKPointAnnotation()
            if i == 0 {
                annotation.title = "A"
            } else if i == 1 {
                annotation.title = "B"
            } else if i == 2 {
                annotation.title = "C"
                addPolygon()
            } else {
                annotation.title = ""
            }
            
            annotation.coordinate = CLLocationCoordinate2D(latitude: CTY[i].placemark.coordinate.latitude, longitude: CTY[i].placemark.coordinate.longitude)
            annotations.append(annotation)
        }
        displayDistance()
        MPView.addAnnotations(annotations)
        MPView.zmft(in: annotations, andShow: true)
    }
}

extension HomeScreenView : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
            self.MPView.setRegion(region, animated: true)
            MPView.showsUserLocation = true
        }
    }
    
}

extension HomeScreenView : SearchCityResult {
    
    func searchedCity(item: MKMapItem) {
        CTY.append(item)
        mrkr()
    }
    
}

extension HomeScreenView : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if Circle == nil {
            let renderer = MKPolylineRenderer(overlay: overlay)
            if overlay.title == "A" {
                renderer.strokeColor = UIColor.blue
            } else if overlay.title == "B" {
                renderer.strokeColor = UIColor.red
            } else if overlay.title == "C" {
                renderer.strokeColor = UIColor.yellow
            }
            renderer.lineWidth = 4.0
            return renderer
        } else {
            let renderer = MKPolygonRenderer(polygon: Circle!)
            renderer.fillColor = UIColor.red.withAlphaComponent(0.50)
            return renderer
        }
    }
}


extension MKPolygon {
    func contain(coor: CLLocationCoordinate2D) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let currentMapPoint: MKMapPoint = MKMapPoint(coor)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
        if polygonRenderer.path == nil {
          return false
        }else{
          return polygonRenderer.path.contains(polygonViewPoint)
        }
    }
}

extension MKMapView {

    
    func zmft() {
        var zoomRect            = MKMapRect.null;
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect       = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01);
            zoomRect            = zoomRect.union(pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }

    
    func zmft(in annotations: [MKAnnotation], andShow show: Bool) {
        var zoomRect:MKMapRect  = MKMapRect.null
    
        for annotation in annotations {
            let aPoint          = MKMapPoint(annotation.coordinate)
            let rect            = MKMapRect(x: aPoint.x, y: aPoint.y, width: 0.1, height: 0.1)
        
            if zoomRect.isNull {
                zoomRect = rect
            } else {
                zoomRect = zoomRect.union(rect)
            }
        }
        if(show) {
            addAnnotations(annotations)
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }

}

