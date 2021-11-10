//
//  Home.swift
//  maps
//
//  Created by jose juan alcantara rincon on 08/11/21.
//

import SwiftUI
import CoreLocation

struct Home: View {
    @StateObject var mapData = MapViewModel()
    @State var locationManager = CLLocationManager()
    @State var activeRoute: Bool = false
    var body: some View {
        ZStack {
            MapView()
                .environmentObject(mapData)
                .ignoresSafeArea(.all, edges: .all)
            VStack {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $mapData.searchTxt)
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(Color.white)
                    
                    if !mapData.places.isEmpty && mapData.searchTxt != "" {
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(mapData.places) { place in
                                    Text(place.place.name ?? "")
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .onTapGesture {
                                            mapData.selectPlace(place: place)
                                            activeRoute = true
                                        }
                                    Divider()
                                }
                            }
                            .padding()
                            .background(Color.white)
                        }
                    }
                }
                .padding()
                Spacer()
                VStack {
                    if activeRoute {
                        Button(action: mapData.makeRoute, label: {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                .font(.title2)
                                .padding(10)
                                .background(Color.primary)
                                .clipShape(Circle())
                        })
                    }
                    Button{
                        mapData.focusLocation()
                        activeRoute = false
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    }
                    Button(action: mapData.updateMapType, label: {
                        Image(systemName: mapData.mapType == .standard ? "network" : "map")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    })
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }
        }
        .onAppear(perform: {
            locationManager.delegate = mapData
            locationManager.requestWhenInUseAuthorization()
        })
        .alert(isPresented: $mapData.permissionDenied, content: {
            Alert(title: Text("Permision Denied"), message: Text("Please enable permission in app settings"), dismissButton: .default(Text("Go to settings"), action: {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }))
        })
        .onChange(of: mapData.searchTxt, perform: { value in
            let delay = 0.3
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay){
                if value == mapData.searchTxt {
                    self.mapData.searchQuery()
                }
            }
        })
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
