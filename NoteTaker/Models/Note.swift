//
//  Note.swift
//  NoteTaker
//
//  Created by Katie on 11/24/20.
//

import Foundation

struct Note: Identifiable {
    var id: String
    var title: String
    var content: String
    var color: String
    var font: String
}

class NoteDetails: ObservableObject {
    @Published var docID: String = ""
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var color: String = ""
    @Published var font: String = ""
}
