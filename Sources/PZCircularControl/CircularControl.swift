//
//  CircularControl.swift
//  PZCircularControl
//
//  Created by Phil Zakharchenko on 12/6/19.
//

import SwiftUI

/// A circular progress control that supports rich customization of appearance and behavior.
public struct CircularControl<Label: View, TrackStyle: ShapeStyle, ProgressStyle: ShapeStyle, KnobStyle: ShapeStyle>: View {
    private let progress: Double
    private let isEditable: Bool
    private let strokeWidth: CGFloat
    private let strokeStyle: CircularControlStyle<TrackStyle, ProgressStyle, KnobStyle>
    private let label: Label
    private let onProgressChange: ((Double) -> Void)?
    
    @State private var currentProgress: Double
    
    @Environment(\.circularControlAllowsWrapping) private var allowsWrapping
    @Environment(\.circularControlKnobScale) private var knobScale
    
    public init(
        progress: Double,
        isEditable: Bool = false,
        strokeWidth: CGFloat = 20,
        style: CircularControlStyle<TrackStyle, ProgressStyle, KnobStyle> = .init(),
        onProgressChange: ((Double) -> Void)? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.progress = progress.clamped(to: 0...1)
        self._currentProgress = State(initialValue: progress.clamped(to: 0...1))
        self.isEditable = isEditable
        self.strokeWidth = strokeWidth
        self.strokeStyle = style
        self.onProgressChange = onProgressChange
        self.label = label()
    }
    
    public var body: some View {
        Track(
            progress: currentProgress,
            isEditable: isEditable,
            strokeWidth: strokeWidth,
            style: strokeStyle,
            onProgressChange: { newProgress in
                currentProgress = newProgress
                onProgressChange?(newProgress)
            }
        )
        .overlay(
            label
                .environment(\.circularControlProgress, currentProgress)
        )
        .onChange(of: progress) { _, newValue in
            currentProgress = newValue.clamped(to: 0...1)
        }
    }
}

// MARK: - Default Label Convenience Initializer

public extension CircularControl where Label == DefaultLabel {
    init(
        progress: Double,
        isEditable: Bool = false,
        strokeWidth: CGFloat = 20,
        style: CircularControlStyle<TrackStyle, ProgressStyle, KnobStyle> = .init(),
        format: DefaultLabelFormat = .percentage,
        onProgressChange: ((Double) -> Void)? = nil
    ) {
        self.init(
            progress: progress,
            isEditable: isEditable,
            strokeWidth: strokeWidth,
            style: style,
            onProgressChange: onProgressChange
        ) {
            DefaultLabel(format: format)
        }
    }
}

// MARK: - Xcode Previews

#Preview {
    VStack {
        CircularControl(
            progress: 0.7,
            isEditable: true,
            style: .init(
                track: Color.indigo.opacity(0.2),
                progress: LinearGradient(
                    colors: [.indigo, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                shadow: .init(color: .purple.opacity(0.3), radius: 10)
            )
        ) { progress in
            print("Progress changed to: \(progress)")
        }
        .circularControlAllowsWrapping(false)
        
        CircularControl(
            progress: 0.4,
            strokeWidth: 25,
            style: .init(
                track: Color.orange.opacity(0.2),
                progress: Color.orange
            )
        ) {
            VStack {
                Image(systemName: "star.fill")
                    .font(.title)
                Text("40%")
                    .font(.headline)
            }
            .foregroundStyle(.orange)
        }
    }
    .padding()
}