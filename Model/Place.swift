//
//  Place.swift
//  maps
//
//  Created by jose juan alcantara rincon on 09/11/21.
//

import SwiftUI
import MapKit

struct Place: Identifiable {
    var id = UUID()
    var place: CLPlacemark
}
