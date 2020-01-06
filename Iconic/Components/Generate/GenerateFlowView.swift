//
//  GenerateFlowView.swift
//  Iconic
//
//  Created by Mohssen Fathi on 12/6/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import SwiftUI
import Combine

class GenerateFlow: ObservableObject {
    
    @Published var isCancelButtonEnabled: Bool = true
    @Published var isDoneButtonEnabled: Bool = false
    @Published var title: String = ""
    @Published var isDismissAlertPresented: Bool = false
    @Published var preventDismissal: Bool = false
    @Published var session: Session
//    @Published var dismissalAttempted: Bool = false
    
    init(session: Session? = nil) {
        self.session = session ?? (try! Session())
    }
    
    let didChange = PassthroughSubject<GenerateFlow, Never>()
    
    var stage: Stage = .resourceSelection {
        didSet { didChange.send(self) }
    }
    
    enum Stage: Int {
        case resourceSelection
        case progress
        case export
    }
    
    func update(to stage: Stage) {
        self.stage = stage
    }
}

struct GenerateFlowView: View {
    
    @ObservedObject var flow: GenerateFlow
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init(session: Session? = nil) {
        self.flow = GenerateFlow(session: session)
    }
    
    var body: some View {
        NavigationView {
            Group {
                GenerateView()
                    .environmentObject(flow)
                    .actionSheet(isPresented: $flow.isDismissAlertPresented, content: {
                        self.saveActionSheet
                    })
            }
            .navigationBarTitle(Text(flow.title), displayMode: .inline)
            .navigationBarItems(leading: cancelButton, trailing: doneButton)
        }
        .onReceive(flow.didChange) { subject in
            self.updateState(subject.stage)
        }
    }
    
    func updateState(_ stage: GenerateFlow.Stage) {
        switch stage {
        case .resourceSelection:
            flow.isCancelButtonEnabled = true
            flow.isDoneButtonEnabled = false
            flow.preventDismissal = true
            flow.title = "Select Image"
        case .progress:
            flow.isCancelButtonEnabled = false
            flow.isDoneButtonEnabled = false
            flow.preventDismissal = true
            flow.title = "Generating Icons..."
        case .export:
            flow.isCancelButtonEnabled = false
            flow.isDoneButtonEnabled = true
            flow.preventDismissal = true
            flow.title = ""
        }
    }
    
    var cancelButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            return Text("Cancel")
                .foregroundColor(.primary)
                .bold()
        })
            .isHidden(!flow.isCancelButtonEnabled)
    }
    
    var doneButton: some View {
        Button(action: {
            self.flow.isDismissAlertPresented = true
        }, label: {
            return Text("Done")
                .foregroundColor(.primary)
                .bold()
        })
            .isHidden(!flow.isDoneButtonEnabled)
    }
    
    
    var saveActionSheet: ActionSheet {
        ActionSheet(
            title: Text("Save Session"),
            message: Text("Would you like to save these assets for later?"),
            buttons: [
                Alert.Button.default(Text("Save"), action: {
                    try? self.flow.session.save()
                    self.presentationMode.wrappedValue.dismiss()
                }),
                Alert.Button.destructive(Text("Delete"), action: {
                    self.flow.session.delete()
                    self.presentationMode.wrappedValue.dismiss()
                }),
                Alert.Button.cancel(Text("Cancel"))
        ])
    }
}

struct GenerateFlowView_Previews: PreviewProvider {
    static var previews: some View {
        return GenerateFlowView()
    }
}
