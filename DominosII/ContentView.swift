//
//  ContentView.swift
//  DominosII
//
//  Created by localadmin on 13.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine

let talkingPublisher = PassthroughSubject<String, Never>()
let mobilePublisher = PassthroughSubject<Void, Never>()


//class sharedDevices: ObservableObject {
//  @Published var devices: [String] {
//    willSet {
//      objectWillChange.send()
//    }
//  }
//
//  init() {
//    self.devices = []
//  }
//}

struct ContentView: View {
  @ObservedObject var mobile = BonjourSearch()
  @State var name: String = ""
  @State var telegram:String = ""
  @State var udpCode = UDPNetwork()
  @State var tcpCode = TCPNetwork()
  @State var message:String = ""
  @State var selected = 0
  
  var body: some View {
    return VStack {
      List(mobile.devices, id: \.device) { item in
        VStack {
          Text(item.device).onTapGesture {
            print("item.device ",item.device)
            self.name = item.device
          }
        }
      }.frame(width: 256, height: 128, alignment: .center)
      
      //      Picker(selection: self.$selected, label: Text("")) {
      //        ForEach(self.mobile.devices, id: \.device) { dix in
      //          Text(dix.device)
      //        }
      //      }.pickerStyle(WheelPickerStyle())
      //        .onTapGesture {
      //          print("You tapped")
      //      }.clipped()
      //        .frame(width: 128, height: 96, alignment: .center)
      
      TextField("Give me stuff to send", text: $telegram, onCommit: {
        //        self.tcpCode.send(self.name)
        self.udpCode.send(self.telegram)
      })
      .multilineTextAlignment(.center)
      .padding(64)
      Text(self.name)
//      Spacer()
      Group {
        Button(action: {
          self.mobile.search()
        }) {
          Text("search")
        }
//        Spacer()
        Button(action: {
          //        self.tcpCode.listenTCP(port: 5418)
          //        self.tcpCode.bonjourTCP("dominoV")
          self.udpCode.bonjourUDP(UIDevice.current.name)
          //          self.udpCode.listenUDP(1854)
        }) {
          Text("start server")
        }
        
//        Spacer()
        Button(action: {
          print("mobile.devices ",self.mobile.devices)
          //        self.tcpCode.connectToTCP(host: "192.168.1.110", port: "1854")
          //        self.tcpCode.bonjourToTCP("dominoV")
          self.udpCode.bonjourToUDP(self.name)
          //          self.udpCode.connectToUDP(host: "192.168.1.110", port: "1854")
        }) {
          Text("connect")
        }
//        Spacer()
        Button(action: {
          self.tcpCode.sendEnd(nil)
        }) {
          Text("disconnect")
        }
//        Spacer()
        Text(message)
          .onReceive(talkingPublisher) { ( data ) in
            self.message = data
        }
      }
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
