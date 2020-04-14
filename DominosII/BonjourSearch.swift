//
//  BonjourSearch.swift
//  DominosII
//
//  Created by localadmin on 14.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit
import Combine

final class BonjourSearch: NSObject, NetServiceBrowserDelegate, NetServiceDelegate, ObservableObject, Identifiable {

 struct objectOf {
    var id:UUID? = UUID()
    var device:String = ""
  }

 @Published var devices: [objectOf] = [] {
    willSet {
      objectWillChange.send()
    }
  }

  var nsb : NetServiceBrowser!
  var services = [NetService]()
//  var devices = [String]()
  
  func search(typeOf:String) {
    print("listening for services...")
    self.services.removeAll()
    devices.removeAll()
    self.nsb = NetServiceBrowser()
    self.nsb.delegate = self
    self.nsb.searchForServices(ofType:typeOf, inDomain: "local")
  }
  
  func updateInterface () {
    for service in self.services {
      if service.port == -1 {
        print("service \(service.name) of type \(service.type)" + " not yet resolved")
        service.delegate = self
        service.resolve(withTimeout:10)
      } else {
        print("service \(service.name) of type \(service.type)," + "port \(service.port), addresses \(service.addresses)")
      }
    }
  }
  
  func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFind aNetService: NetService, moreComing: Bool) {
    print("adding a service")
    self.services.append(aNetService)
    let bean = objectOf(device: aNetService.name)
    devices.append(bean)
    if !moreComing {
      self.updateInterface()
    }
    mobilePublisher.send()
  }
  
  func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
    if let index = self.services.firstIndex(of:aNetService) {
      self.services.remove(at:index)
      devices.remove(at:index)
      print("removing a service")
      if !moreComing {
        self.updateInterface()
      }
    }
    mobilePublisher.send()
  }
}

