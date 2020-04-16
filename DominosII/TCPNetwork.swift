//
//  TCPNetwork.swift
//  DominosII
//
//  Created by localadmin on 14.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit
import Network

let serviceTCPName = "_domino._tcp"

class TCPNetwork: NSObject {
  
  private var talking: NWConnection?
  private var listening: NWListener?
  
   func bonjourTCP(_ called: String) {
    do {
      self.listening = try NWListener(using: .tcp)
      self.listening?.service = NWListener.Service(name:called, type: serviceTCPName, domain: nil, txtRecord: nil)
      self.listening?.serviceRegistrationUpdateHandler = { (serviceChange) in
        switch(serviceChange) {
        case .add(let endpoint):
          switch endpoint {
          case let .service(name, _, _, _):
            print("Service ",name)
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
            print("new TCP connection")
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
  
  func listenTCP( port: Int) {
    let port2U = NWEndpoint.Port.init(integerLiteral: NWEndpoint.Port.IntegerLiteralType(port))
    do {
      self.listening = try NWListener(using: .tcp, on: port2U)
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
            print("new TCP connection")
            self.receive65535(on: newConnection, recursive: true)
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
  
  func connectToTCP(host: String, port:String) {
    let hostTCP = NWEndpoint.Host.init(host)
    let portTCP = NWEndpoint.Port.init(port)!
    self.talking = NWConnection(host: hostTCP, port: portTCP, using: .tcp)
    self.talking?.stateUpdateHandler = { (newState) in
      switch (newState) {
      case .ready:
        print("new TCP connection")
        break
      default:
        break
      }
    }
    self.talking?.start(queue: .main)
  }
  
  func bonjourToTCP(_ called:String) {
    if called.isEmpty {
      alertPublisher.send()
      return
    }
    self.talking = NWConnection(to: .service(name: called, type: serviceTCPName, domain: "local", interface: nil), using: .tcp)
    self.talking?.stateUpdateHandler = { (newState) in
      switch (newState) {
      case .ready:
        print("new TCP connection")
      default:
        break
      }
    }
    self.talking?.start(queue: .main)
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
          talkingPublisher.send(backToString + " TCP")
        }
      }
      if connection.state == .ready && isComplete == false && recursive {
        self.receive(on: connection, recursive: true)
      }
    }
  }
  
  var tcpLink = false
  var tcpConnection: NWConnection?
  
  func resetTCPLink() {
    tcpLink = false
    tcpConnection = nil
  }
  
  // 65535 is the maximum number of fragments for an IPv4 datagram or TCP packet
  func receive65535(on connection: NWConnection, recursive: Bool) {
    connection.receive(minimumIncompleteLength: 1, maximumLength: 65535) { (data, context, isComplete, error) in
      debugPrint("\(Date()) TcpReader: got a message \(String(describing: data?.count)) bytes")
      if let content = data {
        DispatchQueue.main.async {
          let backToString = String(decoding: content, as: UTF8.self)
          talkingPublisher.send(backToString + " TCP")
        }
        self.tcpLink = true
        self.tcpConnection = connection
      }
      
      if connection.state == .ready && isComplete == false && recursive {
        self.receive65535(on: connection, recursive: true)
      }
    }
  }
  

  

  
  func send(_ content: String?) {
    if tcpLink {
      specialTCPSend(on: tcpConnection!, content: content!)
      return
    }
    let contentToSendTCP = content?.data(using: String.Encoding.utf8)
    self.talking?.send(content: contentToSendTCP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError == nil) {
        // This is pickup any immediate response
        self.receive65535(on: self.talking!, recursive: false)
      } else {
        print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
      }
    })))
  }
  
  func sendEnd(_ content: String?) {
    let contentToSendTCP = content?.data(using: String.Encoding.utf8)
    self.talking?.send(content: contentToSendTCP, contentContext: NWConnection.ContentContext.finalMessage, isComplete: true, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError == nil) {
        resetPublisher.send()
//        self.talking?.cancel()
      } else {
        print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
      }
    })))
  }
  
    func specialTCPSend(on connection: NWConnection, content:String) {
    let contentToSendTCP = content.data(using: String.Encoding.utf8)
      connection.send(content: contentToSendTCP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError == nil) {
        // This is pickup any immediate response
        self.receive65535(on: connection, recursive: false)
      } else {
        print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
      }
    })))
    connection.start(queue: .main)
  }
  
  func superTCPSend(content:String) {
    let contentToSendUDP = content.data(using: String.Encoding.utf8)
      let context = NWConnection.ContentContext(identifier: "Yo", expiration: 1, priority: 1, isFinal: true, antecedent: nil, metadata: nil)
        self.talking?.send(content: contentToSendUDP, contentContext: context, isComplete: true, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError == nil) {
        // This is pickup any immediate response
//        self.receive(on: self.talking, recursive: false)
      } else {
        print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
      }
    })))
  }
  
}
