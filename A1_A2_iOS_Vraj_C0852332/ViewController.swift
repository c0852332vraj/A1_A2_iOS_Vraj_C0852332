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
    override func viewDidLoad() {
        super.viewDidLoad()

        if (CLLocationManager.locationServicesEnabled())
              {
            locManage = CLLocationManager()
            locManage.delegate = self
            locManage.desiredAccuracy = kCLLocationAccuracyBest
            locManage.requestAlwaysAuthorization()
            locManage.startUpdatingLocation()
              }
              let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(tabbedLong))
              self.mapView.addGestureRecognizer(longPressRecognizer)
    }

    @objc func tabbedLong(sender: UILongPressGestureRecognizer) {
           print("tabbedLong")
           let alert = UIAlertController(title: "Test", message: "Add the city?", preferredStyle: .alert)

           alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
               let searchVC = self.storyboard?.instantiateViewController(withIdentifier: "searchTableCell") as! searchViewController
               searchVC.mapView = self.mapView
               searchVC.delegate = self
               self.navigationController?.pushViewController(searchVC, animated: true)
             }))

           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in

             }))

           present(alert, animated: true, completion: nil)
       }

}

extension ViewController : CLLocationManagerDelegate {
    func locManage(_ manager: CLLocationManager, toUpdateLocs locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0))
            self.mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
            
        }
    }
}

extension ViewController : citySearchOutcome {

    func citySearched(item: MKMapItem) {
        cityArray.append(item)

        var annotations = [MKAnnotation]()

        for i in 0..<cityArray.count {
            let annotation = MKPointAnnotation()
            if i == 0 {
                annotation.title = "A"
            } else if i == 1 {
                annotation.title = "B"
            } else if i == 2 {
                annotation.title = "C"
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
extension MKMapView {
    func fitWhole() {
        var zoomRect            = MKMapRect.null;
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

