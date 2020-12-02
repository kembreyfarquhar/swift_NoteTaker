//
//  Widgets.swift
//  NoteTaker
//
//  Created by Katie on 11/26/20.
//

import SwiftUI
import Combine
import UIKit

//struct ExDivider: View {
//    let color: Color = .init(UIColor.lightGray)
//    let width: CGFloat = 1
//    var body: some View {
//        Rectangle()
//            .fill(color)
//            .frame(height: width)
//            .edgesIgnoringSafeArea(.horizontal)
//    }
//}

struct Indicator : UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<Indicator>) -> UIActivityIndicatorView {
        
        let view = UIActivityIndicatorView(style: .medium)
        view.startAnimating()
        return view
    }
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Indicator>) {
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

// OBSERVING NOTIFICATIONS I MADE TO SNAP THE TOOLBAR INTO THE PLACE I WANT
class KeyboardResponder: ObservableObject {

    @Published var currentHeight: CGFloat = 0

    var _center: NotificationCenter
    
    @objc func keyBoardWillHide(notification: Notification) {
            withAnimation {
               currentHeight = 0
            }
        }
    
    @objc func keyBoardWillAppear(notification: Notification) {
            withAnimation {
               currentHeight = 5
            }
        }

        init(center: NotificationCenter = .default) {
            _center = center
            _center.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: Notification.Name("KeyboardHidden"), object: nil)
            _center.addObserver(self, selector: #selector(keyBoardWillAppear(notification:)), name: Notification.Name("KeyboardAppeared"), object: nil)
        }
}

// KEYBOARD MODIFIER FOR VIEWS TO MOVE UPWARD AS KEYBOARD APPEARS
fileprivate final class KeyboardObserver: ObservableObject {
    struct Info {
        let curve: UIView.AnimationCurve
        let duration: TimeInterval
        let endFrame: CGRect
    }
     
    private var observers = [NSObjectProtocol]()
     
    init() {
        let handler: (Notification) -> Void = { [weak self] notification in
            self?.keyboardInfo = Info(notification: notification)
        }
        let names: [Notification.Name] = [
            UIResponder.keyboardWillShowNotification,
            UIResponder.keyboardWillHideNotification,
            UIResponder.keyboardWillChangeFrameNotification
        ]
        observers = names.map({ name in
            NotificationCenter.default.addObserver(forName: name,
                                                   object: nil,
                                                   queue: .main,
                                                   using: handler)
        })
    }
 
    @Published var keyboardInfo = Info(curve: .linear, duration: 0, endFrame: .zero)
}
 
fileprivate extension KeyboardObserver.Info {
    init(notification: Notification) {
        guard let userInfo = notification.userInfo else { fatalError() }
        curve = {
            let rawValue = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
            return UIView.AnimationCurve(rawValue: rawValue)!
        }()
        duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
    }
}


struct KeyboardVisibility: ViewModifier {
    @ObservedObject fileprivate var keyboardObserver = KeyboardObserver()
 
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            withAnimation() {
                content.padding(.bottom, max(0, self.keyboardObserver.keyboardInfo.endFrame.height - geometry.safeAreaInsets.bottom))
                    .animation(Animation(keyboardInfo: self.keyboardObserver.keyboardInfo))
            }
        }
    }
}
 
fileprivate extension Animation {
    init(keyboardInfo: KeyboardObserver.Info) {
        switch keyboardInfo.curve {
        case .easeInOut:
            self = .easeInOut(duration: keyboardInfo.duration)
        case .easeIn:
            self = .easeIn(duration: keyboardInfo.duration)
        case .easeOut:
            self = .easeOut(duration: keyboardInfo.duration)
        case .linear:
            self = .linear(duration: keyboardInfo.duration)
        @unknown default:
            self = .easeInOut(duration: keyboardInfo.duration)
        }
    }
}

extension View {
    func keyboardVisibility() -> some View {
        return modifier(KeyboardVisibility())
    }
}
