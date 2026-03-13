import SwiftUI
import AppKit

// MARK: - Design Tokens

enum DS {
    static let cornerSM:   CGFloat = 6
    static let cornerMD:   CGFloat = 10
    static let cornerLG:   CGFloat = 14

    static let iconSize:   CGFloat = 28
    static let iconRadius: CGFloat = 7

    static let rowH:       CGFloat = 46
    static let rowPadH:    CGFloat = 16
    static let rowPadV:    CGFloat = 9
}

// MARK: - KeyBadge

struct KeyBadge: View {
    let keys: [String]

    init(_ keys: String...) { self.keys = keys }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(keys, id: \.self) { key in
                Text(key)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.primary.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .strokeBorder(Color.primary.opacity(0.14), lineWidth: 0.5)
                            )
                    )
            }
        }
    }
}

// MARK: - IconBadge

struct IconBadge: View {
    let systemName: String
    let color: Color
    var size: CGFloat = DS.iconSize

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.47, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(color.gradient)
            .clipShape(RoundedRectangle(cornerRadius: DS.iconRadius))
    }
}

// MARK: - PrefsGroupBox

struct PrefsGroupBox<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: DS.cornerMD))
            .overlay(
                RoundedRectangle(cornerRadius: DS.cornerMD)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
            )
    }
}

// MARK: - PrefsToggleRow

struct PrefsToggleRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: iconColor)
            VStack(alignment: .leading, spacing: 1) {
                Text(title).font(.system(size: 13))
                if let sub = subtitle {
                    Text(sub).font(.system(size: 11)).foregroundColor(.secondary)
                }
            }
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden()
        }
        .padding(.horizontal, DS.rowPadH)
        .padding(.vertical, DS.rowPadV)
        .contentShape(Rectangle())
    }
}

// MARK: - PrefsSliderRow

struct PrefsSliderRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double.Stride
    let unit: String

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: iconColor)
            Text(title).font(.system(size: 13))
            Spacer()
            Slider(value: $value, in: range, step: step)
                .frame(width: 110)
            Text("\(value, specifier: "%.1f")\(unit)")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
        .padding(.horizontal, DS.rowPadH)
        .padding(.vertical, DS.rowPadV)
    }
}

// MARK: - PrefsButtonRow

struct PrefsButtonRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    var subtitle: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                IconBadge(systemName: icon, color: iconColor)
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(.system(size: 13)).foregroundColor(.primary)
                    if let sub = subtitle {
                        Text(sub).font(.system(size: 11)).foregroundColor(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, DS.rowPadH)
            .padding(.vertical, DS.rowPadV)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - InsetDivider

struct InsetDivider: View {
    var body: some View {
        Divider().padding(.leading, 56)
    }
}

// MARK: - SectionLabel

struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.secondary)
            .tracking(0.3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
            .padding(.top, 20)
            .padding(.bottom, 6)
    }
}

// MARK: - PageTitle

struct PageTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 17, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 4)
    }
}
