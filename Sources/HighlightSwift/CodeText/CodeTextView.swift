import SwiftUI

@available(iOS 16.1, tvOS 16.1, *)
extension CodeText: View {
    public var body: some View {
        Text(attributedText)
            .fontDesign(.monospaced)
            .padding(.vertical, style.verticalPadding)
            .padding(.horizontal, style.horizontalPadding)
            .background {
                if let cardStyle = style as? CardCodeTextStyle {
                    CodeTextCardView(
                        style: cardStyle,
                        color: highlightResult?.backgroundColor
                    )
                }
            }
            .onAppear {
                guard highlightResult == nil else {
                    return
                }
                refreshHighlight()
            }
            .onDisappear {
                highlightTask?.cancel()
            }
            .onChange(of: mode) { newMode in
                refreshHighlight(mode: newMode)
            }
            .onChange(of: colors) { newColors in
                refreshHighlight(colors: newColors)
            }
            .onChange(of: colorScheme) { newColorScheme in
                refreshHighlight(colorScheme: newColorScheme)
            }
            .onChange(of: scenePhase) { newPhase in
                guard newPhase == .active else {
                    return
                }
                refreshHighlight()
            }
    }

    @MainActor
    private func refreshHighlight(
        mode: HighlightMode? = nil,
        colors: CodeTextColors? = nil,
        colorScheme: ColorScheme? = nil
    ) {
        highlightTask?.cancel()
        highlightTask = Task { @MainActor in
            await highlightText(mode: mode, colors: colors, colorScheme: colorScheme)
        }
    }
}

//  MARK: - Preview

@available(iOS 16.1, tvOS 16.1, *)
private struct PreviewCodeText: View {
    @State var colors: CodeTextColors = .theme(.xcode)
    @State var font: Font = .body

    let code: String = """
    import SwiftUI
    
    struct SwiftUIView: View {
        var body: some View {
            Text("Hello World!")
        }
    }
    """
    
    var body: some View {
        List {
            CodeText(code)
                .codeTextStyle(.card)
                .codeTextColors(colors)
                .highlightLanguage(.swift)
                .font(font)
            Button {
                withAnimation {
                    colors = .theme(randomTheme())
                    font = randomFont()
                }
            } label: {
                Text("Random")
            }
        }
    }
    
    func randomTheme() -> HighlightTheme {
        let cases = HighlightTheme.allCases
        return cases[.random(in: 0..<cases.count)]
    }
    
    func randomFont() -> Font {
        let cases: [Font] = [
            .body,
            .callout,
            .caption,
            .caption2,
            .footnote,
            .headline,
            .largeTitle,
            .subheadline,
            .title
        ]
        return cases[.random(in: 0..<cases.count)]
    }
}

@available(iOS 16.1, tvOS 16.1, *)
#Preview {
    PreviewCodeText()
}
