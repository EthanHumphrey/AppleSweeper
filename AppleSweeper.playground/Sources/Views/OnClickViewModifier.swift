import AppKit
import SwiftUI

struct ClickableSwiftUIView: NSViewRepresentable {
    
    @Binding var isHighlighted: Bool
    let onLeftClick: (() -> Void)?
    let onRightClick: (() -> Void)?
    
    func updateNSView(_ nsView: ClickableView, context: NSViewRepresentableContext<ClickableSwiftUIView>) {
        
    }

    func makeNSView(context: Context) -> ClickableView {
        ClickableView(isHighlighted: $isHighlighted, onLeftClick: self.onLeftClick, onRightClick: self.onRightClick)
    }

}

class ClickableView : NSView {
    
    @Binding var isHighlighted: Bool
    let onLeftClick: (() -> Void)?
    let onRightClick: (() -> Void)?
    
    init(isHighlighted: Binding<Bool>, onLeftClick: (() -> Void)?, onRightClick: (() -> Void)?) {
        _isHighlighted = isHighlighted
        self.onLeftClick = onLeftClick
        self.onRightClick = onRightClick
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    override func mouseDown(with theEvent: NSEvent) {
        isHighlighted = true
    }

    override func rightMouseDown(with theEvent: NSEvent) {
        isHighlighted = true
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        isHighlighted = false
        if let handler = onLeftClick, self.frame.contains(self.convert(theEvent.locationInWindow, from: nil)) {
            handler()
        }
    }

    override func rightMouseUp(with theEvent: NSEvent) {
        isHighlighted = false
        if let handler = onRightClick, self.frame.contains(self.convert(theEvent.locationInWindow, from: nil)) {
            handler()
        }
    }
    
}

struct OnClick: ViewModifier {
    @Binding var isHighlighted: Bool
    let leftClick: (() -> Void)?
    let rightClick: (() -> Void)?
    func body(content: Content) -> some View {
        return ZStack {
            AnyView(content)
            ClickableSwiftUIView(isHighlighted: $isHighlighted, onLeftClick: leftClick, onRightClick: rightClick)
        }
    }
}
