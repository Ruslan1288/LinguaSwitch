import AppKit

class FloatingIndicatorWindow: NSPanel {
    static let shared = FloatingIndicatorWindow()
    private var hideTimer: Timer?
    private let label = NSTextField(labelWithString: "")

    private static let indicatorWidth: CGFloat  = 30
    private static let indicatorHeight: CGFloat = 18

    private init() {
        let size = NSRect(x: 0, y: 0,
                          width:  FloatingIndicatorWindow.indicatorWidth,
                          height: FloatingIndicatorWindow.indicatorHeight)
        super.init(contentRect: size,
                   styleMask: [.borderless, .nonactivatingPanel],
                   backing: .buffered, defer: false)
        isOpaque = false
        backgroundColor = .clear
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        ignoresMouseEvents = true

        let bgFrame = NSRect(x: 0, y: 0,
                             width:  FloatingIndicatorWindow.indicatorWidth,
                             height: FloatingIndicatorWindow.indicatorHeight)
        let bg = NSVisualEffectView(frame: bgFrame)
        bg.material = NSVisualEffectView.Material.hudWindow
        bg.state = NSVisualEffectView.State.active
        bg.wantsLayer = true
        bg.layer?.cornerRadius = 4
        bg.alphaValue = 0.85
        contentView = bg

        label.font = .systemFont(ofSize: 10, weight: .semibold)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: bg.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: bg.centerYAnchor),
            label.widthAnchor.constraint(equalTo: bg.widthAnchor, constant: -4)
        ])
    }

    func show(_ text: String, isTypo: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.label.stringValue = text
            self.label.textColor = isTypo && AppSettings.shared.changeIndicatorColorOnTypo ? .systemRed : .labelColor
            let mouse = NSEvent.mouseLocation
            self.setFrameOrigin(NSPoint(x: mouse.x + 14, y: mouse.y + 6))
            self.alphaValue = 1
            self.orderFront(nil)
            self.hideTimer?.invalidate()
            let delay = AppSettings.shared.autoHideIndicatorDelay
            self.hideTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
                NSAnimationContext.runAnimationGroup({ ctx in
                    ctx.duration = 0.2
                    self?.animator().alphaValue = 0
                }, completionHandler: {
                    self?.orderOut(nil)
                    self?.alphaValue = 1
                })
            }
        }
    }
}
