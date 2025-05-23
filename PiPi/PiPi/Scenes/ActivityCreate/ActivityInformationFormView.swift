//
//  ActivityInformationFormView.swift
//  PiPi
//
//  Created by 정상윤 on 8/1/24.
//

import SwiftUI
import _MapKit_SwiftUI

struct ActivityInformationFormView: View {
    
    @Binding var title: String
    @Binding var description: String
    @Binding var maxPeopleNumber: Int
    @Binding var category: Activity.Category
    @Binding var startDateTime: Date
    @Binding var estimatedTime: Int?
    @Binding var location: Coordinates?
    
    var body: some View {
        Form {
            titleSection
            descriptionSection
            maxPeopleNumberSection
            categoryPicker
            dateTimeLocationSection
            locationLink
        }
        .onAppear (perform : UIApplication.shared.hideKeyboard)
    }
}

private extension ActivityInformationFormView {
    
    var titleSection: some View {
        Section {
            TextField("제목을 입력해주세요.", text: $title)
        } header: {
            header(title: "제목", subtitle: nil)
        }
    }
    
    var descriptionSection: some View {
        Section {
            TextEditor(text: $description)
        } header: {
            header(title: "설명", subtitle: nil)
        }
    }
    
    var maxPeopleNumberSection: some View {
        Section {
            Stepper("\(maxPeopleNumber)", value: $maxPeopleNumber, in: 2...20)
        } header: {
            header(title: "최대인원", subtitle: "20명까지 가능합니다.")
        }
    }
    
    var categoryPicker: some View {
        Picker(selection: $category) {
            ForEach(Activity.Category.allCases, id: \.self) { category in
                Text(category.rawValue).tag(category as Activity.Category?)
            }
        } label: {
            Text("카테고리")
        }
    }
    
    var dateTimeLocationSection: some View {
        Section {
            DatePicker("시작 일시", selection: $startDateTime, in: Date()...)
            estimatedTimePicker
        }
    }
    
    var estimatedTimePicker: some View {
        Picker(selection: $estimatedTime) {
            Text("미정").tag(nil as Int?)
            ForEach(1..<6) { time in
                Text("\(time)").tag(time as Int?)
            }
        } label: {
            Text("예상 소요시간")
        }
    }
    
    var locationLink: some View {
        Section {
            NavigationLink(destination: {
                LocationSelectView(coordinates: $location)
                    .navigationBarBackButtonHidden()
            }) {
                HStack {
                    Text("위치")
                    Text(location == nil ? "" : "선택 완료")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            if let location {
                Map(
                    position: .constant(.camera(.init(centerCoordinate: .init(location), distance: 1000)))
                ) {
                    Marker("", coordinate: .init(location))
                        .tint(.accent)
                }
                .disabled(true)
                .frame(height: 150)
                .cornerRadius(10)
            }
        } header: {
            header(title: "위치 지정", subtitle: nil)
        }
    }
    
    func header(title: String, subtitle: String?) -> some View {
        HStack {
            Text(title)
                .sectionHeaderAppearance()
            if let subtitle {
                Text(subtitle)
                    .font(.caption)
            }
        }
        .setListRowInsets()
    }
    
}

fileprivate extension Text {
    
    func sectionHeaderAppearance() -> some View {
        self
            .foregroundStyle(.black)
            .font(.callout)
            .fontWeight(.regular)
            .setListRowInsets()
    }
    
}

fileprivate extension View {
    
    func setListRowInsets() -> some View {
        self.listRowInsets(.init(top: 15, leading: 8, bottom: 8, trailing: 15))
    }
    
}

extension UIApplication {
    func hideKeyboard() {
        guard let window = windows.first else { return }
        let tapRecognizer = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        window.addGestureRecognizer(tapRecognizer)
    }
 }
 
extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}


#Preview {
    ActivityInformationFormView(
        title: .constant(""),
        description: .constant(""),
        maxPeopleNumber: .constant(2),
        category: .constant(.cafe),
        startDateTime: .constant(Date()),
        estimatedTime: .constant(nil),
        location: .constant(nil)
    )
}
