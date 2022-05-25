//
//  ViewController.swift
//  A1_A2_iOS_Vraj_C0852332
//
//  Created by Vraj Patel on 24/05/22.
//
import MapKit
import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet var mapView: MKMapView!
    
    var locManage: CLLocationManager!
    var cityArray : [MKMapItem] = []
    var polygon: MKPolygon? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.navigationController?.isNavigationBarHidden = true
       
        if (CLLocationManager.locationServicesEnabled())
              {
            locManage = CLLocationManager()
            locManage.delegate = self
            locManage.desiredAccuracy = kCLLocationAccuracyBest
            locManage.requestAlwaysAuthorization()
            locManage.startUpdatingLocation()
              }
              let tabbedLongRegonize = UILongPressGestureRecognizer(target: self, action: #selector(tabbedLong))
              self.mapView.addGestureRecognizer(tabbedLongRegonize)
    }
    
    func addPolygon() {
           var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()

           for i in 0..<cityArray.count {
               points.append(cityArray[i].placemark.coordinate)
           }

           let polygon = MKPolygon(coordinates: points, count: points.count)
           self.polygon = polygon
           mapView.addOverlay(polygon)
       }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            if let touch = touches.first {
                if touch.tapCount == 1 {
                    let touchLocation = touch.location(in: self.mapView)
                    let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)

                    for polygon in mapView.overlays as! [MKPolygon] {
                        let renderer = MKPolygonRenderer(polygon: polygon)
                        let mapPoint = MKMapPoint(locationCoordinate)
                        let viewPoint = renderer.point(for: mapPoint)
                        if polygon.contain(coor: locationCoordinate) {
                            print("into the range")
                            checkPoint(location: locationCoordinate)
                        } else {
                            print("out of range")
                        }
                    }
                }
            }

            super.touchesEnded(touches, with: event)
        }
    
    func checkPoint(location : CLLocationCoordinate2D) {
          var arrDistance : [Double] = []
          for i in 0..<cityArray.count {
              let dist = getDistance(source: location, destination: cityArray[i].placemark.coordinate)
              arrDistance.append(dist)
          }
          let ss = arrDistance.max { a, b in
              return a > b
          }
          var index = 0
          for i in 0..<arrDistance.count {
              if ss == arrDistance[i] {
                  index = i
                  break
              }
          }
          cityArray.remove(at: index)
          mapView.removeAnnotations(mapView.annotations)
          if mapView.overlays.last != nil {
              mapView.removeOverlay(mapView.overlays.last!)
          }
          DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              self.addAnnotations()
          }
        
        func getDistance(source : CLLocationCoordinate2D, destination : CLLocationCoordinate2D) ->  Double {
             let coordinate₀ = CLLocation(latitude: source.latitude, longitude: source.longitude)
             let coordinate₁ = CLLocation(latitude: destination.latitude, longitude: destination.longitude)

             let distanceInMeters = coordinate₀.distance(from: coordinate₁)
             return Double(distanceInMeters)
         }
    
     @objc func tabbedLong(sender: UILongPressGestureRecognizer) {
           print("tabbedLong")
           let alert = UIAlertController(title: "Test", message: "Add the city?", preferredStyle: .alert)

           alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
               let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "searchViewController") as! searchViewController
               searchVC.mapView = self.mapView
               searchVC.delegate = self
               self.navigationController?.pushViewController(searchVC, animated: true)
             }))

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in

             }))

           present(alert, animated: true, completion: nil)
       }
   }
}
    extension ViewController : CLLocationManagerDelegate {
        func locManage(_ manager: CLLocationManager, toUpadateLocs locations: [CLLocation]) {
            if let location = locations.last{
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
                self.mapView.setRegion(region, animated: true)
                mapView.showsUserLocation = true
            }
        }
        
        func addAnnotations() {
            var annotations = [MKAnnotation]()
            for i in 0..<cityArray.count {
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
                
                annotation.coordinate = CLLocationCoordinate2D(latitude: cityArray[i].placemark.coordinate.latitude, longitude: cityArray[i].placemark.coordinate.longitude)
                annotations.append(annotation)
            }
            mapView.addAnnotations(annotations)
            mapView.fitWhole(in: annotations, andShow: true)
        }
    }

    extension ViewController : citySearchOutcome {
        
        func citySearched(item: MKMapItem) {
            cityArray.append(item)
            addAnnotations()
        }
        
    }

    extension ViewController : MKMapViewDelegate {
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if polygon == nil {
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
                let renderer = MKPolygonRenderer(polygon: polygon!)
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

    func fitWhole() {
        var zoomRect = MKMapRect.null;
        for annotation in annotations {
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect       = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01);
            zoomRect            = zoomRect.union(pointRect);
        }
        setVisibleMapRect(zoomRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
    }

    func fitWhole(in annotations: [MKAnnotation], andShow show: Bool) {
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






