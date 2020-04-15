//
//  UDPNetwork.swift
//  DominosII
//
//  Created by localadmin on 14.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit
import Network

let serviceUDPName = "_domino._udp"



  



class UDPNetwork: NSObject, NetServiceDelegate, NetServiceBrowserDelegate {
  
  private var talking: NWConnection?
  private var listening: NWListener?
  
  func bonjourUDP(_ called: String) {
    do {
      self.listening = try NWListener(using: .udp)
      self.listening?.service = NWListener.Service(name:called, type: serviceUDPName, domain: nil, txtRecord: nil)
      self.listening?.serviceRegistrationUpdateHandler = { (serviceChange) in
        switch(serviceChange) {
        case .add(let endpoint):
          switch endpoint {
          case let .service(name: name, type: type, domain: domain, interface: interface):
            print("Service ",name,type,domain,interface)
          default:
            break
          }
        case .remove(let endpoint):
          switch endpoint {
          case let .service(name: name, type: type, domain: domain, interface: interface):
            print("Service ",name,type,domain,interface)
          default:
            break
          }
        default:
          break
        }
      }
      self.listening?.stateUpdateHandler = {(newState) in
        switch newState {
        case .ready:
          print("ready")
        default:
          break
        }
      }
      self.listening?.newConnectionHandler = {(newConnection) in
        newConnection.stateUpdateHandler = {newState in
          switch newState {
          case .ready:
            print("new UDP connection")
            self.receive(on: newConnection, recursive: true)
          default:
            break
          }
        }
        newConnection.start(queue: DispatchQueue(label: "new client"))
      }
    } catch {
      print("unable to create listener")
    }
    self.listening?.start(queue: .main)
  }
  
  func listenUDP(_  port: Int) {
    let port2U = NWEndpoint.Port.init(integerLiteral: NWEndpoint.Port.IntegerLiteralType(port))
    do {
      self.listening = try NWListener(using: .udp, on: port2U)
      self.listening?.stateUpdateHandler = {(newState) in
        switch newState {
        case .ready:
          print("ready")
        default:
          break
        }
      }
      self.listening?.newConnectionHandler = {(newConnection) in
        newConnection.stateUpdateHandler = {newState in
          switch newState {
          case .ready:
            print("new UDP connection")
            self.receive8192(on: newConnection, recursive: true)
          default:
            break
          }
        }
        newConnection.start(queue: DispatchQueue(label: "new client"))
      }
    } catch {
      print("unable to create listener")
    }
    self.listening?.start(queue: .main)
  }
  
  var udpLink = false
  var udpConnection: NWConnection?
  
  func resetTCPLink() {
    udpLink = false
    udpConnection = nil
  }
  
  func superUDPSend(on connection: NWConnection, content:String) {
    let contentToSendUDP = content.data(using: String.Encoding.utf8)
      let context = NWConnection.ContentContext(identifier: "Yo", expiration: 1, priority: 1, isFinal: true, antecedent: nil, metadata: nil)
      connection.send(content: contentToSendUDP, contentContext: context, isComplete: true, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError == nil) {
        // This is pickup any immediate response
        self.receive(on: connection, recursive: false)
      } else {
        print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
      }
    })))
  }
  
  func specialUDPSend(on connection: NWConnection, content:String) {
    let contentToSendUDP = content.data(using: String.Encoding.utf8)
      connection.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError == nil) {
        // This is pickup any immediate response
        self.receive(on: connection, recursive: false)
      } else {
        print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
      }
    })))
    connection.start(queue: .main)
  }
  
  func receive(on connection: NWConnection, recursive: Bool) {
      print("listening")
      connection.receiveMessage { (data, context, isComplete, error) in
        if let error = error {
          print(error)
          return
        }
        if let content = data, !content.isEmpty {
          DispatchQueue.main.async {
          let backToString = String(decoding: content, as: UTF8.self)
          talkingPublisher.send(backToString + " UDP")
        }
        
        }
        if connection.state == .ready && isComplete == false && recursive {
          self.receive(on: connection, recursive: true)
        }
      }
  }
  
  // 8192 is the maximum number of fragments for an IPv4 datagram or UDP packet
  
  func receive8192(on connection: NWConnection, recursive: Bool) {
    connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { (data, context, isComplete, error) in
//        debugPrint("\(Date()) TcpReader: got a message \(String(describing: content?.count)) bytes")
        if let content = data {
            DispatchQueue.main.async {
          let backToString = String(decoding: content, as: UTF8.self)
          talkingPublisher.send(backToString + " UDP")
        }
        self.udpLink = true
        self.udpConnection = connection
        }
        if connection.state == .ready && isComplete == false && recursive {
          self.receive8192(on: connection, recursive: true)
        }
    }
  }
  
  func bonjourToUDP(_ called:String) {
    self.talking = NWConnection(to: .service(name: called, type: serviceUDPName, domain: "local", interface: nil), using: .udp)
    self.talking?.stateUpdateHandler = { (newState) in
      switch (newState) {
      case .ready:
        print("new UDP connection")
      default:
        break
      }
    }
    self.talking?.start(queue: .main)
  }
  
  func connectToUDP(host:String,port:String) {
    let hostUDP = NWEndpoint.Host.init(host)
    let portUDP = NWEndpoint.Port.init(port)!
    self.talking = NWConnection(host: hostUDP, port: portUDP, using: .udp)
    self.talking?.stateUpdateHandler = { (newState) in
      switch (newState) {
      case .ready:
        print("new UDP connection")
      default:
        break
      }
    }
    self.talking?.start(queue: .main)
  }
  
  func send(_ content: String?) {
    if udpLink {
      specialUDPSend(on: udpConnection!, content: content!)
      return
    }
    let contentToSendUDP = content?.data(using: String.Encoding.utf8)
    self.talking?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError == nil) {
        // This is pickup any immediate response
        self.receive(on: self.talking!, recursive: false)
      } else {
        print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
      }
    })))
  }
  
}