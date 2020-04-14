//
//  ContentView.swift
//  DominosII
//
//  Created by localadmin on 13.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine
import Foundation

let talkingPublisher = PassthroughSubject<String, Never>()

func nodeName() {
  var name = UIDevice.current.name
  print("name ",name)
//  uname(&name)
//  return withUnsafePointer(to: &name.nodename) {
//    String.init(cString: UnsafePointer(&name.nodename))
//  }
}

let foo = myNetService()

struct ContentView: View {
  @State var name: String = ""

  @State var udpCode = UDPNetwork()
  @State var tcpCode = TCPNetwork()
  @State var message:String = ""

  
  
  var body: some View {
    return VStack {
      Button(action: {
        foo.search()
      }) {
        Text("search")
      }
      Spacer()
      Group {

      Button(action: {
//        self.tcpCode.listenTCP(port: 5418)
//        self.tcpCode.bonjourTCP("dominoV")
        self.udpCode.bonjourUDP(UIDevice.current.name)
//          self.udpCode.listenUDP(1854)
      }) {
        Text("start server")
      }
      
      Spacer()
      Button(action: {
//        self.tcpCode.connectToTCP(host: "192.168.1.110", port: "1854")
//        self.tcpCode.bonjourToTCP("dominoV")
        self.udpCode.bonjourToUDP(UIDevice.current.name)
//          self.udpCode.connectToUDP(host: "192.168.1.110", port: "1854")
      }) {
        Text("connect")
      }
      Spacer()
      Button(action: {
        self.tcpCode.sendEnd(nil)
      }) {
        Text("disconnect")
      }
      Spacer()
       TextField("Give me stuff to send", text: $name, onCommit: {
//        self.tcpCode.send(self.name)
        self.udpCode.send(self.name)
       })
      Spacer()
      Text(message)
         .onReceive(talkingPublisher) { ( data ) in
            self.message = data
        }
      Spacer()
      }
    }
  }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
