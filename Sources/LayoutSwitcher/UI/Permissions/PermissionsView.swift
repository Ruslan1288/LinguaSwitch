import SwiftUI
import AppKit

// MARK: - State

class PermissionsViewState: ObservableObject {
    @Published var accessibilityGranted: Bool = AccessibilityHelper.isAccessibilityGranted()
    @Published var inputMonitoringGranted: Bool = AccessibilityHelper.isInputMonitoringGranted()

    var allGranted: Bool { AccessibilityHelper.allPermissionsGranted() }

    private var timer: Timer?

    func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.accessibilityGranted = AccessibilityHelper.isAccessibilityGranted()
                self?.inputMonitoringGranted = AccessibilityHelper.isInputMonitoringGranted()
            }
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Main View

struct PermissionsView: View {
    @StateObject private var state = PermissionsViewState()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            Divider()
            permissionRow(
                step: 1,
                title: L("permissions.accessibility.title"),
                description: L("permissions.accessibility.description"),
                granted: state.accessibilityGranted,
                action: {
                    AccessibilityHelper.requestAccessibility()
                    AccessibilityHelper.openAccessibilitySettings()
                }
            )
            permissionRow(
                step: 2,
                title: L("permissions.input_monitoring.title"),
                description: L("permissions.input_monitoring.description"),
                granted: state.inputMonitoringGranted,
                action: {
                    AccessibilityHelper.requestInputMonitoring()
                    AccessibilityHelper.openInputMonitoringSettings()
                }
            )
            Divider()
            footer
        }
        .padding(24)
        .frame(width: 460)
        .onAppear { state.startPolling() }
        .onDisappear { state.stopPolling() }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 36))
                .foregroundColor(.accentColor)
            VStack(alignment: .leading, spacing: 3) {
                Text(L("permissions.title"))
                    .font(.title2).bold()
                Text(L("permissions.subtitle"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var footer: some View {
        Group {
            if state.allGranted {
                HStack {
                    Label(L("permissions.all_granted"), systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Spacer()
                    Button(L("permissions.restart")) {
                        AppDelegate.shared?.relaunch()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Text(L("permissions.hint"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func permissionRow(step: Int, title: String, description: String, granted: Bool, action: @escaping () -> Void) -> some View {
        HStack(alignment: .top, spacing: 14) {
            stepBadge(step: step, granted: granted)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(title).font(.headline)
                    Spacer()
                    Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(granted ? .green : .red)
                }
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if !granted {
                    Button(L("permissions.open_settings"), action: action)
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .padding(.top, 2)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(granted ? Color.green.opacity(0.05) : Color.primary.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(granted ? Color.green.opacity(0.3) : Color.primary.opacity(0.08), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func stepBadge(step: Int, granted: Bool) -> some View {
        ZStack {
            Circle()
                .fill(granted ? Color.green : Color.accentColor.opacity(0.12))
                .frame(width: 28, height: 28)
            if granted {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text("\(step)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.accentColor)
            }
        }
    }
}
