//
//  ContentView.swift
//  DominosII
//
//  Created by localadmin on 13.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine

enum MyAppPage {
  case Menu
  case SecondPage
}

struct ListView: View {
  @Binding var name:String
  @State var device: String
  @State var isSelected: Bool
  
  var body: some View {
    Text(device)
      .listRowBackground(self.isSelected ? Color.yellow: Color.clear)
      .onTapGesture {
        self.name = self.device
        self.isSelected = !self.isSelected
    }
  }
}

var prime = false
var firstRun = true

final class MyAppEnvironmentData: ObservableObject {
  @Published var currentPage : MyAppPage? = .Menu
  @Published var currentClient: String = ""
//  @Published var udpCode = udpProcess
  @Published var udpCode = UDPNetwork()
//  @Published var tcpCode = TCPNetwork()
}

struct NavigationTest: View {
  var body: some View {
    NavigationView {
      PageOne()
    }
  }
}


struct PageOne: View {
  @EnvironmentObject var env : MyAppEnvironmentData
  @ObservedObject var mobile = BonjourBrowser()
  @State var name: String = ""
  @State var telegram:String = ""
//  @State var udpCode = UDPNetwork()
//  @State var tcpCode = TCPNetwork()
  @State var message:String = ""
  
  @State var startSvr = false
  @State var searchSvr = false
  @State var connectSvr = false
  @State var stopStr = false
  @State var showingAlert = false
  
  @State var background = Color.yellow
  // maximum 32 players in the room
  @State var isSelected = [Bool](repeating: false, count: 32)
  @State var index = 0
  
  
  var body: some View {
    let navlink = NavigationLink(destination: PageTwo(),
                                 tag: .SecondPage,
                                 selection: $env.currentPage,
                                 label: { EmptyView() })
    
    return VStack {
      List {
        ForEach(mobile.devices, id: \.self) { each in
          ListView(name: self.$name, device: each.device, isSelected: false)
        }
      }
      .font(Fonts.avenirNextCondensedBold(size: 16))
      .frame(width: 256, height: 128, alignment: .center)
      Text("Dominoes").font(.largeTitle)
        .padding()
        .onAppear(perform: {
          if firstRun {
            firstRun = false
//          let queue = DispatchQueue(label: "foo", qos: .utility, attributes: .concurrent)
          DispatchQueue.main.async {
            self.env.udpCode.bonjourUDP(UIDevice.current.name)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
              self.mobile.seek(typeOf: serviceUDPName)
            })
          }
          }
        })
      
        .onReceive(resetPublisher) { (_) in
          self.name = ""
      }
      .onReceive(alertPublisher, perform: { (_) in
        self.showingAlert = true
      })
        .alert(isPresented: $showingAlert) {
          Alert(title: Text("No client selected"), message: Text("Sorry, You need to select a client first"), dismissButton: .default(Text("Try Again!")))
      }.onReceive(nextPagePublisher) { ( clientName ) in
//        self.udpCode.bonjourToUDP(clientName)
        self.env.currentClient = clientName
        self.env.currentPage = .SecondPage
        prime = false
      }
      
      navlink
        .frame(width:0, height:0)
      
      EmptyView()
      
      Button("Play") {
        prime = true
        self.env.udpCode.bonjourToUDP(self.name)
        self.env.currentClient = self.name
        self.env.currentPage = .SecondPage
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
          self.env.udpCode.sendUDP("@ComePlay:" + UIDevice.current.name)
        })
      }
      .padding()
      .border(Color.primary)
      
    }
  }
  
}


//struct PageTwo: View {
//  @State var message: String = "Phew"
//  @EnvironmentObject var env : MyAppEnvironmentData
//
//  var body: some View {
//    VStack {
//      Text("Page Two").font(.largeTitle).padding()
//      Text(message)
//        .font(Fonts.avenirNextCondensedBold(size: 16))
//        .padding()
//        .onReceive(talkingPublisher) { ( data ) in
//          self.message = "received " + data
//      }
//
//      Text("Go Back")
//        .padding()
//        .border(Color.primary)
//        .onTapGesture {
//
//          self.env.currentPage = .Menu
//      }
//    }.navigationBarBackButtonHidden(true)
//  }
//}

#if DEBUG
struct NavigationTest_Previews: PreviewProvider {
  static var previews: some View {
    NavigationTest().environmentObject(MyAppEnvironmentData())
  }
}
#endif
//
let talkingPublisher = PassthroughSubject<String, Never>()
let mobilePublisher = PassthroughSubject<Void, Never>()
let resetPublisher = PassthroughSubject<Void, Never>()
let alertPublisher = PassthroughSubject<Void, Never>()
let nextPagePublisher = PassthroughSubject<String, Never>()

struct Fonts {
  static func avenirNextCondensedBold (size:CGFloat) -> Font{
    return Font.custom("AvenirNextCondensed-Bold",size: size)
  }
  
  static func zapfino (size:CGFloat) -> Font{
    return Font.custom("Zapfino",size: size)
  }
}


struct TalkView: View {
  @ObservedObject var mobile = BonjourBrowser()
  @State var name: String = ""
  @State var telegram:String = ""
  @State var udpCode = UDPNetwork()
  @State var tcpCode = TCPNetwork()
  @State var message:String = ""
  
  @State var startSvr = false
  @State var searchSvr = false
  @State var connectSvr = false
  @State var stopStr = false
  @State var showingAlert = false
  
  @State var background = Color.yellow
  @State var isSelected = false
  
  var body: some View {
    return VStack {
      List {
        ForEach(mobile.devices, id: \.self) { each in
          Text(each.device)
            .onTapGesture {
              self.name = each.device
              self.isSelected = !self.isSelected
          }
        }
        .font(Fonts.avenirNextCondensedBold(size: 16))
        .listRowBackground(isSelected ? Color.yellow: Color.clear)
      }
      .font(Fonts.avenirNextCondensedBold(size: 16))
      .frame(width: 256, height: 128, alignment: .center)
      
      TextField("sending What ", text: $telegram, onCommit: {
        self.udpCode.sendUDP(self.telegram)
        //        self.tcpCode.send(self.telegram)
        //        self.tcpCode.superTCPSend(content: self.telegram)
      })
        .font(Fonts.avenirNextCondensedBold(size: 16))
        .multilineTextAlignment(.center)
        .padding(64)
      Text("sending To " + self.name)
        .font(Fonts.avenirNextCondensedBold(size: 16))
        .padding()
        .onReceive(resetPublisher) { (_) in
          self.name = ""
      }
      .onReceive(alertPublisher, perform: { (_) in
        self.showingAlert = true
      })
        .alert(isPresented: $showingAlert) {
          Alert(title: Text("No client selected"), message: Text("Sorry, You need to select a client first"), dismissButton: .default(Text("Try Again!")))
      }
      Text(message)
        .font(Fonts.avenirNextCondensedBold(size: 16))
        .padding()
        .onReceive(talkingPublisher) { ( data ) in
          self.message = "received " + data
      }
      Group {
        HStack {
          Image("Image-1")
            .resizable()
            .frame(width: 32, height: 32, alignment: .center)
            .overlay(
              Image("Image-Back")
                .resizable()
                .opacity(0.4)
                .frame(width: 48, height: 48, alignment: .center)
          )
          Text("start server")
            .font(Fonts.avenirNextCondensedBold(size: 16))
            .foregroundColor(Color.blue)
            .background(startSvr ? Color.yellow:Color.clear)
            .onTapGesture {
              self.startSvr = true
              //      self.tcpCode.listenTCP(port: 5418)
              //        self.tcpCode.bonjourTCP(UIDevice.current.name)
              self.udpCode.bonjourUDP(UIDevice.current.name)
              //      self.udpCode.listenUDP(1854)
          }.padding()
        }
        HStack {
          Image("Image-2")
            .resizable()
            .frame(width: 32, height: 32, alignment: .center)
            .overlay(
              Image("Image-Back")
                .resizable()
                .opacity(0.4)
                .frame(width: 48, height: 48, alignment: .center)
          )
          Text("search & select device")
            .foregroundColor(Color.blue)
            .background(searchSvr ? Color.yellow:Color.clear)
            .font(Fonts.avenirNextCondensedBold(size: 16))
            .onTapGesture {
              self.searchSvr = true
              self.mobile.seek(typeOf: serviceUDPName)
              //            self.mobile.seek(typeOf: serviceTCPName)
              self.tcpCode.resetTCPLink()
          }
          .padding()
        }
        HStack {
          Image("Image-3")
            .resizable()
            .frame(width: 32, height: 32, alignment: .center)
            .overlay(
              Image("Image-Back")
                .resizable()
                .opacity(0.4)
                .frame(width: 48, height: 48, alignment: .center)
          )
          Text("connect")
            .font(Fonts.avenirNextCondensedBold(size: 16))
            .foregroundColor(Color.blue)
            .background(connectSvr ? Color.yellow:Color.clear)
            .onTapGesture {
              self.connectSvr = true
              print("mobile.devices ",self.mobile.devices)
              //        self.tcpCode.connectToTCP(host: "192.168.1.110", port: "1854")
              //          self.tcpCode.bonjourToTCP(self.name)
              self.udpCode.bonjourToUDP(self.name)
              //         self.udpCode.connectToUDP(host: "192.168.1.110", port: "1854")
          }
          .padding()
        }
        HStack {
          Image("Image-4")
            .resizable()
            .frame(width: 32, height: 32, alignment: .center)
            .overlay(
              Image("Image-Back")
                .resizable()
                .opacity(0.4)
                .frame(width: 48, height: 48, alignment: .center)
          )
          
          Text("disconnect")
            .font(Fonts.avenirNextCondensedBold(size: 16))
            .background(stopStr ? Color.yellow:Color.clear)
            .onTapGesture {
              self.stopStr = true
              self.tcpCode.sendEnd(nil)
          }
          .padding()
        }
      }
    }
  }
}



struct DominoesView_Previews: PreviewProvider {
  static var previews: some View {
    TalkView()
  }
}
