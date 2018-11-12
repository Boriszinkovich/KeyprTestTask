//
//  MainVCPresenter.swift
//  KeyprTestTask
//
//  Created by User on 11.11.2018.
//  Copyright © 2018 bzink. All rights reserved.
//

import UIKit
import CoreData

protocol MainVCPresenterProtocol: NSObjectProtocol {
    func onViewCreate()
    func onRefresh()
    func getCitiesCount() -> Int
    func getCityModel(indexPath: IndexPath) -> CityCellViewModel?
}

class MainVCPresenter: NSObject {

    weak var mainVC: MainVCProtocol?
    weak var weatherService: WeatherService?
    
    private lazy var fetchedResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: City.self))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderId", ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.sharedInstance.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    init(weatherService: WeatherService, mainVC: MainVCProtocol) {
        super.init()
        self.weatherService = weatherService
        self.weatherService?.delegate = self
        self.mainVC = mainVC
    }
}

extension MainVCPresenter: MainVCPresenterProtocol {
    
    func onViewCreate() {
        self.adjustInternet()
        self.subscribeToInternetNotification()
        do {
            try self.fetchedResultController.performFetch()
        } catch let error  {
            print("ERROR: \(error)")
        }
    }
    
    func onRefresh() {
        _ = self.weatherService!.forceLoadWeather()
    }
    
    func getCitiesCount() -> Int {
        if let count = fetchedResultController.sections?.first?.numberOfObjects {
            return count
        }
        return 0
    }
    
    func getCityModel(indexPath: IndexPath) -> CityCellViewModel? {
        if let city = fetchedResultController.object(at: indexPath) as? City {
            let model = CityCellViewModel(city: city, api: self.weatherService!.api)
            return model
        }
        return nil
    }
}

extension MainVCPresenter: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .update {
            self.mainVC?.reloadTable(pathArray: [indexPath!])
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.mainVC?.endTableUpdate()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.mainVC?.startTableUpdate()
    }
}

extension MainVCPresenter: WeatherServiceDelegate {
    
    func weatherServiceDidFinishLoading() {
        self.mainVC?.endWeatherRefreshing()
    }
    
    func weatherServiceDidStartLoading() {
        self.mainVC?.startWeatherRefreshing()
    }
    
    func weatherServiceFailedLoading(error: WeatherServiceError) {
        switch error {
        case .ApiError(let message):
            self.mainVC?.showError(message: message)
        default:
            break
        }
    }
}

private extension MainVCPresenter {
    
    private func subscribeToInternetNotification() {
        //        // Register an observer for the network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: NetworkManager.sharedInstance.reachability
        )
    }
    
    private var noInternetText: String {
        let offlineMode = "Offline mode.".localized()
        guard let lastUpdatedDate = self.weatherService?.lastUpdateDate else {
            return offlineMode
        }
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "HH:mm"
        let dateString = dateFormatterGet.string(from: lastUpdatedDate)
        return offlineMode + "This weather was actual at ".localized() + dateString
    }
    
    @objc private func networkStatusChanged(_:Notification) {
        DispatchQueue.main.async {
            self.adjustInternet()
        }
    }
    
    private func adjustInternet() {
        self.mainVC?.adjustInternet(show: NetworkManager.isReachable(), message: self.noInternetText)
    }
}
