//
//  Date+Ext.swift
//  MeuNegocio
//
//  Created by Leonardo Portes on 28/09/22.
//

import Foundation

extension Date {
    
    func toString(format: String = "dd/MM/yyyy") -> String {
        return Self.formatter(format: format).string(from: self)
    }
    
    private static func formatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter
    }
    
    static func getDates(forLastNDays nDays: Int) -> [String] {
        let cal = NSCalendar.current
        // start with today
        var date = cal.startOfDay(for: Date())
        date = cal.date(byAdding: .day, value: 1, to: date)!

        var arrDates = [String]()

        for _ in 1 ... nDays {
            date = cal.date(byAdding: .day, value: -1, to: date)!
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: date)
            arrDates.append(dateString)
        }
        return arrDates
    }
    
    static func getDatesOfCurrentMonth() -> [String] {
          let dateFormatter = DateFormatter()
          dateFormatter.dateFormat = "dd"
          let currentDayString = dateFormatter.string(from: Date())
          let currentDay = Int(currentDayString) ?? 0

          let cal = NSCalendar.current
          var date = cal.startOfDay(for: Date())
          date = cal.date(byAdding: .day, value: 1, to: date)!

          var arrDates = [String]()

          for _ in 1 ... currentDay {
              date = cal.date(byAdding: .day, value: -1, to: date)!

              let dateFormatter = DateFormatter()
              dateFormatter.dateFormat = "dd/MM/yyyy"
              let dateString = dateFormatter.string(from: date)
              arrDates.append(dateString)
          }
          return arrDates
      }

}
