//
//  GeneralHelper.swift
//  SmartWallet
//
//  Created by Soheil on 07/04/2018.
//  Copyright © 2018 Soheil Novinfard. All rights reserved.
//

import Foundation

enum MonthYearArrayType {
	case monthsStringArray
	case monthsIntArray
	case monthsWithyear
	case monthsWithyearExceptCurrent
	case monthsWithyearExceptCurrentTuple
}

enum RecordType {
	case recordTypeCost
	case recordTypeIncome
	case recordTypeAll
}

enum CategoryType {
	case categoryTypeCost
	case categoryTypeIncome
	case categoryTypeAll
}

func getCurrencyLabel() -> String {
	let currencyLabel = UserDefaults.standard.string(forKey: "currencySymbol") ?? ""
	return currencyLabel
}

func monthsBetweenDates(startDate: Date?, endDate: Date?, displayType: MonthYearArrayType) -> Array<Any> {
	let dateFormtter = DateFormatter()

	var monthsStringArray = [String]()
	var monthsIntArray = [Int]()
	var monthsWithyear = [String]()
	var monthsWithyearExceptCurrent = [String]()
	var monthsWithyearExceptCurrentTuple = [(year: Int, month: Int, title: String)]()
	dateFormtter.dateFormat = "MM"

	if let startYear: Int = startDate?.year(), let endYear = endDate?.year() {

		if let startMonth: Int = startDate?.month(), let endMonth: Int = endDate?.month() {
			for year in startYear...endYear {
				for month in (year == startYear ? startMonth : 1)...(year < endYear ? 12 : endMonth) {
					let monthTitle = dateFormtter.monthSymbols[month - 1]
					monthsStringArray.append(monthTitle)
					monthsIntArray.append(month)

					let monthWithYear = "\(monthTitle) \(year)"
					monthsWithyear.append(monthWithYear)

					let exceptCurrent: String
					if year == Date().year() {
						exceptCurrent = monthTitle
					} else {
						exceptCurrent = monthWithYear
					}
					monthsWithyearExceptCurrent.append(exceptCurrent)
					monthsWithyearExceptCurrentTuple.append((year, month, exceptCurrent))
				}
			}
		}

	}

	switch displayType {
	case .monthsWithyear:
		return monthsWithyear
	case .monthsWithyearExceptCurrent:
		return monthsWithyearExceptCurrent
	case .monthsStringArray:
		return monthsStringArray
	case .monthsIntArray:
		return monthsIntArray
	case .monthsWithyearExceptCurrentTuple:
		return monthsWithyearExceptCurrentTuple
	}
}

func getMonthDuration(year: Int, month: Int, considerCurrent: Bool) -> Int {
	let dateComponents = DateComponents(year: year, month: month)
	let calendar = Calendar.current
	let date = calendar.date(from: dateComponents)!

	let range = calendar.range(of: .day, in: .month, for: date)!
	var numDays = range.count

	if considerCurrent {
		if year == Date().year() && month == Date().month() {
			numDays = Date().day()
		}
	}

	return numDays
}

func getRecordString(_ value: Double, _ type: RecordType, preciseDecimal: Int = 2, formatting: Bool = true) -> String {
	var prefix = ""
	if type == .recordTypeAll {
		if value >= 0 {
			prefix = "+"
		} else {
			prefix = "-"
		}
	} else if type == .recordTypeIncome {
		prefix = "+"
	} else {
		prefix = "-"
	}
	let absValue = abs(value)

	let formatter = NumberFormatter()
	formatter.minimumFractionDigits = 0
	formatter.maximumFractionDigits = 2

	if formatting {
		return "\(prefix) \(getCurrencyLabel()) \(absValue.format(formatString: ".\(preciseDecimal)"))"
	} else {

//		return String(format:"\(prefix) \(getCurrencyLabel()) %g", absValue)
		return "\(prefix) \(getCurrencyLabel()) \(formatter.string(from: NSNumber(value: absValue))!)"
	}

}

func getDateOnlyFromDatetime(_ date: Date) -> Date {

	let dateFormatter = DateFormatter()
	dateFormatter.timeStyle = DateFormatter.Style.none
	dateFormatter.dateStyle = DateFormatter.Style.short
	let dateString = dateFormatter.string(from: date)

	return dateFormatter.date(from: dateString)!
}

func getDoubleFromLocalNumber(input: String) -> Double {
	var value = 0.0
	let numberFormatter = NumberFormatter()
	let decimalFiltered = input.replacingOccurrences(of: "٫|,", with: ".", options: .regularExpression)
	numberFormatter.locale = Locale(identifier: "EN")
	if let amountValue = numberFormatter.number(from: decimalFiltered) {
		value = amountValue.doubleValue
	}
	return value
}

extension Date {
	func month() -> Int {
		let month = Calendar.current.component(.month, from: self)
		return month
	}

	func year() -> Int {
		let year = Calendar.current.component(.year, from: self)
		return year
	}

	func day() -> Int {
		let day = Calendar.current.component(.day, from: self)
		return day
	}

	func startOfMonth() -> Date {
		let day = Calendar.current.startOfDay(for: self)
		return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month],from: day))!
	}

	func endOfMonth() -> Date {
		return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
	}
}

extension Int {
	func format(formatString: String) -> String {
		return String(format: "%\(formatString)d", self)
	}
}

extension Double {
	func format(formatString: String) -> String {
		return String(format: "%\(formatString)f", self)
	}
	var clean: String {
		return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
	}
}
