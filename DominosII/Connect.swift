//
//  Connect.swift
//  DominosII
//
//  Created by localadmin on 13.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import UIKit
import Network

class Connect: NSObject {
  
  private var talking: NWConnection?
  private var listening: NWListener?
  
  
  func listenUDP( port: Int) {
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
            self.receive(on: newConnection)
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
  
  func receive(on connection: NWConnection) {
      print("listening")
      connection.receiveMessage { (data, context, isComplete, error) in
        if let error = error {
          print(error)
          return
        }
        if let data = data, !data.isEmpty {
          let backToString = String(decoding: data, as: UTF8.self)
          print("b2S",backToString)
        }
        if connection.state == .ready && isComplete == false {
          print("more")
          self.receive(on: connection)
        }
      }
  }
  
  func receive8192(on connection: NWConnection) {
    connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { (content, context, isComplete, error) in
        debugPrint("\(Date()) TcpReader: got a message \(String(describing: content?.count)) bytes")
        if let content = content {
            print("content ",content)
        }
        if connection.state == .ready && isComplete == false {
          self.receive(on: connection)
        }
    }
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
            self.receive8192(on: newConnection)
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
  
  func connectToTCP(hostTCP:NWEndpoint.Host,portTCP:NWEndpoint.Port) {
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
  
  func connectToUDP(hostUDP:NWEndpoint.Host,portUDP:NWEndpoint.Port) {
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

    let contentToSendUDP = content?.data(using: String.Encoding.utf8)
    self.talking?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError == nil) {
        self.specialreceive8192(on: self.talking!)
      } else {
        print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
      }
    })))
  }
  
  func sendMore(_ content: String?) {
    let contentToSendUDP = content?.data(using: String.Encoding.utf8)
    self.talking?.send(content: contentToSendUDP, contentContext: NWConnection.ContentContext.defaultMessage, isComplete: false, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError == nil) {
        self.specialreceive8192(on: self.talking!)
      } else {
        print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
      }
    })))
  }
  
  func sendEnd(_ content: String?) {
    let contentToSendUDP = content?.data(using: String.Encoding.utf8)
    self.talking?.send(content: contentToSendUDP, contentContext: NWConnection.ContentContext.finalMessage, isComplete: true, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
      if (NWError == nil) {
//        self.talking?.cancel()
      } else {
        print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
      }
    })))
  }
  
   func specialreceive8192(on connection: NWConnection) {
    connection.receive(minimumIncompleteLength: 1, maximumLength: 8192) { (content, context, isComplete, error) in
      debugPrint("\(Date()) TcpReader: got a message \(String(describing: content?.count)) bytes")
      if let data = content {
        let backToString = String(decoding: data, as: UTF8.self)
        print("content ",content,backToString)
        DispatchQueue.main.async {
          talkingPublisher.send(backToString + "Connect")
        }

          

        }
        
        print("deciding 8192 ",isComplete,context?.isFinal)
        if isComplete {
//          print("closing connection")
//          connection.cancel()
        }
        if connection.state == .ready && isComplete == false {
          print("here 8192 ",isComplete,context?.isFinal)
//            self.receive8192(on: connection)
          }
        if connection.state == .cancelled {
          print("goodbye")
        }
    }
  }
  
}
