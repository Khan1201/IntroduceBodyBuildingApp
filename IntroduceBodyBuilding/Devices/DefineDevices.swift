import Foundation

import DeviceKit

public enum DeviceGroup {
   case fourInches
   case fiveInches
   case xSeries
   case iPads
    
   public var rawValue: [Device] {
      switch self {
      case .fourInches:
          return [.iPhone5s, .iPhoneSE]
      case .fiveInches:
          return [.iPhone6, .iPhone6s, .iPhone7, .iPhone8, .simulator(.iPhoneSE3)]
      case .xSeries:
          return Device.allDevicesWithSensorHousing
      case .iPads:
         return Device.allPads
      }
   }
}
class DeviceManager {
   static let shared: DeviceManager = DeviceManager()
    
    func isFourIncheDevices() -> Bool {
        return Device.current.isOneOf(DeviceGroup.fourInches.rawValue)
    }
    
   func isFiveIncheDevices() -> Bool {
      return Device.current.isOneOf(DeviceGroup.fiveInches.rawValue)
   }
   func isIPadDevices() -> Bool {
      return Device.current.isOneOf(DeviceGroup.iPads.rawValue)
   }
}
