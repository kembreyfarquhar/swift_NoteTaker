//
//  NotesList.swift
//  NoteTaker
//
//  Created by Katie on 11/24/20.
//

import SwiftUI
import FirebaseFirestore
import Firebase

class NotesList: ObservableObject {
    @Published var notes = [Note]()
    @Published var noData = false
    private var db = Firestore.firestore()
    
    init() {
        getData()
    }
    
    func getData() {
        Firestore.firestore().clearPersistence()
        let db = Firestore.firestore()
        db.collection("notes").addSnapshotListener { (snap, err) in
            if err != nil {
                print((err?.localizedDescription)!)
                self.noData = true
                return
            }
            if (snap?.documentChanges.isEmpty)!{
                self.noData = true
                return
            }
            
            
            for i in (snap?.documentChanges)!{
                let id = i.document.documentID
                
                if i.type == .added{
                    let content = i.document.data()["content"] as! String
                    let color = i.document.data()["color"] as! String
                    let font = i.document.data()["font"] as! String
                    DispatchQueue.main.async {
                        self.notes.append(Note(id: id, content: content, color: color, font: font))
                    }
                    self.noData = false
                }
                
                if i.type == .modified{
                    let content = i.document.data()["content"] as! String
                    let color = i.document.data()["color"] as! String
                    let font = i.document.data()["font"] as! String
                    for j in 0..<self.notes.count{
                        if self.notes[j].id == id {
                            self.notes[j].content = content
                            self.notes[j].color = color
                            self.notes[j].font = font
                        }
                    }
                }
                
                if i.type == .removed{
                    print(self.notes.count)
                    for j in 0..<self.notes.count{
                        if self.notes[j].id == id {
                            print("J: \(j)")
                            print("FB ID: \(id)")
                            print("NOTE ID: \(self.notes[j].id)")
                            print(self.notes[j].content)
                            self.notes.remove(at: j)
                            if self.notes.isEmpty {
                                self.noData = true
                            }
                            return
                        }
                    }
                }
            }
        }
    }
}

