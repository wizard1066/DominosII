//
//  BonjourSearch.swift
//  DominosII
//
//  Created by localadmin on 14.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit

class BonjourSearch: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
  
  var nsb : NetServiceBrowser!
  var services = [NetService]()
  
  func search() {
    print("listening for services...")
    self.services.removeAll()
    self.nsb = NetServiceBrowser()
    self.nsb.delegate = self
    self.nsb.searchForServices(ofType:"_domino._udp", inDomain: "local")
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
    if !moreComing {
      self.updateInterface()
    }
  }
  
  func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemove aNetService: NetService, moreComing: Bool) {
    if let index = self.services.firstIndex(of:aNetService) {
      self.services.remove(at:index)
      print("removing a service")
      if !moreComing {
        self.updateInterface()
      }
    }
  }
}

