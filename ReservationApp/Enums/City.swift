//
//  City.swift
//  ReservationApp
//
//  Created by Mahmut Arslan on 15.11.2025.
//

import Foundation

/// Turkish cities
enum City: String, Codable, CaseIterable, Identifiable {
    case adana = "Adana"
    case adiyaman = "Adıyaman"
    case afyonkarahisar = "Afyonkarahisar"
    case agri = "Ağrı"
    case aksaray = "Aksaray"
    case amasya = "Amasya"
    case ankara = "Ankara"
    case antalya = "Antalya"
    case ardahan = "Ardahan"
    case artvin = "Artvin"
    case aydin = "Aydın"
    case balikesir = "Balıkesir"
    case bartin = "Bartın"
    case batman = "Batman"
    case bayburt = "Bayburt"
    case bilecik = "Bilecik"
    case bingol = "Bingöl"
    case bitlis = "Bitlis"
    case bolu = "Bolu"
    case burdur = "Burdur"
    case bursa = "Bursa"
    case canakkale = "Çanakkale"
    case cankiri = "Çankırı"
    case corum = "Çorum"
    case denizli = "Denizli"
    case diyarbakir = "Diyarbakır"
    case duzce = "Düzce"
    case edirne = "Edirne"
    case elazig = "Elazığ"
    case erzincan = "Erzincan"
    case erzurum = "Erzurum"
    case eskisehir = "Eskişehir"
    case gaziantep = "Gaziantep"
    case giresun = "Giresun"
    case gumushane = "Gümüşhane"
    case hakkari = "Hakkari"
    case hatay = "Hatay"
    case igdir = "Iğdır"
    case isparta = "Isparta"
    case istanbul = "İstanbul"
    case izmir = "İzmir"
    case kahramanmaras = "Kahramanmaraş"
    case karabuk = "Karabük"
    case karaman = "Karaman"
    case kars = "Kars"
    case kastamonu = "Kastamonu"
    case kayseri = "Kayseri"
    case kilis = "Kilis"
    case kirikkale = "Kırıkkale"
    case kirklareli = "Kırklareli"
    case kirsehir = "Kırşehir"
    case kocaeli = "Kocaeli"
    case konya = "Konya"
    case kutahya = "Kütahya"
    case malatya = "Malatya"
    case manisa = "Manisa"
    case mardin = "Mardin"
    case mersin = "Mersin"
    case mugla = "Muğla"
    case mus = "Muş"
    case nevsehir = "Nevşehir"
    case nigde = "Niğde"
    case ordu = "Ordu"
    case osmaniye = "Osmaniye"
    case rize = "Rize"
    case sakarya = "Sakarya"
    case samsun = "Samsun"
    case sanliurfa = "Şanlıurfa"
    case siirt = "Siirt"
    case sinop = "Sinop"
    case sirnak = "Şırnak"
    case sivas = "Sivas"
    case tekirdag = "Tekirdağ"
    case tokat = "Tokat"
    case trabzon = "Trabzon"
    case tunceli = "Tunceli"
    case usak = "Uşak"
    case van = "Van"
    case yalova = "Yalova"
    case yozgat = "Yozgat"
    case zonguldak = "Zonguldak"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue
    }
    
    // Popular cities for quick access
    static var popularCities: [City] {
        [.istanbul, .ankara, .izmir, .antalya, .bursa, .adana, .gaziantep, .konya]
    }
    
    // Sort cities alphabetically for display
    static var sortedCities: [City] {
        allCases.sorted { $0.rawValue < $1.rawValue }
    }
}









