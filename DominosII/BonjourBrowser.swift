//
//  BonjourSearch.swift
//  DominosII
//
//  Created by localadmin on 14.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit
import Combine
import Network

final class BonjourBrowser: NSObject, ObservableObject, Identifiable {
  
  struct objectOf:Hashable {
    var id:UUID? = UUID()
    var device:String = ""
    var IsIndexed:Int = 0
  }
  
  @Published var devices: [objectOf] = [] {
    willSet {
      objectWillChange.send()
    }
  }
  
  var browser: NWBrowser!
  
  func seek(typeOf: String) {
    let bonjourTCP = NWBrowser.Descriptor.bonjour(type: typeOf , domain: nil)
    let bonjourParms = NWParameters.init()
    browser = NWBrowser(for: bonjourTCP, using: bonjourParms)
    browser.stateUpdateHandler = {newState in
      switch newState {
      case .ready:
        print("new bonjour connection")
      default:
        break
      }
    }
    browser.browseResultsChangedHandler = { ( results, changes ) in
//      for result in results {
//        if case .service(let service) = result.endpoint {
//          print("bonjourA ",service.name)
//          let device = objectOf(device: service.name)
//          self.devices.append(device)
//        }
//      }
      for change in changes {
        if case .added(let added) = change {
          if case .service(let service) = added.endpoint {
            let device = objectOf(device: service.name, IsIndexed: self.devices.count)
            self.devices.append(device)
//            mobilePublisher.send()
          }
          if case .removed(let removed) = change {
            if case .service(let service) = removed.endpoint {
              let index = self.devices.firstIndex(where:{$0.device == service.name })
              self.devices.remove(at: index!)
//              mobilePublisher.send()
            }
          }
        }
        
        
      }
    }
    self.browser.start(queue: DispatchQueue.main)
  }
  
}

//final class BonjourSearch: NSObject, NetServiceBrowserDelegate, NetServiceDelegate, ObservableObject, Identifiable {
//
//
//  struct objectOf {
//    var id:UUID? = UUID()
//    var device:String = ""
//  }
//
//  @Published var devices: [objectOf] = [] {
//    willSet {
//      objectWillChange.send()
//    }
//  }
//
//  var nsb : NetServiceBrowser!
//  var services = [NetService]()
//  //  var devices = [String]()
//
//  func search(typeOf:String) {
//    let seeker = BonjourBrowser()
//    seeker.seek(typeOf: serviceTCPName)
//    //
//    //    print("listening for services...")
//    //    self.services.removeAll()
//    //    devices.removeAll()
//    //    self.nsb = NetServiceBrowser()
//    //    self.nsb.delegate = self
//    //    self.nsb.searchForServices(ofType:typeOf, inDomain: "local")
//  }
//
//  func updateInterface () {
//    for service in self.services {
//      if service.port == -1 {
//        print("service \(service.name) of type \(service.type)" + " not yet resolved")
//        service.delegate = self
//        service.resolve(withTimeout:10)
//      } else {
//        print("service \(service.name) of type \(service.type)," + "port \(service.port), addresses \(service.addresses)")
//      }
//    }
//  }
//
//  func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
//    print("adding a service")
//    self.services.append(aNetService)
//    let bean = objectOf(device: aNetService.name)
//    devices.append(bean)
//    if !moreComing {
//      self.updateInterface()
//    }
//    //    mobilePublisher.send()
//  }
//
//  func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
//    if let index = self.services.firstIndex(of:aNetService) {
//      self.services.remove(at:index)
//      devices.remove(at:index)
//      print("removing a service")
//      if !moreComing {
//        self.updateInterface()
//      }
//    }
//    //    mobilePublisher.send()
//  }
//}

