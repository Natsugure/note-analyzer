//
//  DashboardListRow.swift
//  noteAnalyzer
//
//  Created by Natsugure on 2025/01/16.
//

import SwiftUI

struct DashboardListRow: View {
    var element: ListElement
    
    var body: some View {
        HStack {
            VStack {
                Text("\(element.date, formatter: dateFormatter)")
                Text(dateToTimeString(date: element.date))
            }
            .frame(maxWidth: .infinity)
            Text("\(element.articleCount)")
                .frame(width: 40)
            ZStack {
                AppConstants.BrandColor.read.opacity(0.5)
                Text("\(element.totalReadCount)")
            }
            .frame(width: 80)
            ZStack {
                AppConstants.BrandColor.comment.opacity(0.3)
                Text("\(element.totalCommentCount)")
            }
            .frame(width: 60)
            ZStack {
                AppConstants.BrandColor.likeBackground
                Text("\(element.totalLikeCount)")
            }
            .frame(width: 60)
        }
        .font(.system(size: 12))
    }
    
    private func dateToTimeString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
}

//#Preview {
//    DashboardListRow()
//}
