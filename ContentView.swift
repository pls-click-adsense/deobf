import SwiftUI

struct ContentView: View {
    @State private var inputText = ""
    @State private var outputText = ""

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $inputText)
                    .frame(height: 250)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                    .padding()
                
                Button(action: deobfuscate) {
                    Text("Deobfuscate (MoonSec)")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                TextEditor(text: $outputText)
                    .frame(height: 250)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.blue.opacity(0.5)))
                    .padding()
                
                Button("Copy Result") {
                    UIPasteboard.general.string = outputText
                }
                .padding(.bottom)
            }
            .navigationTitle("Lua Deobfuscator")
        }
    }

    func deobfuscate() {
        // \数字 形式をデコードするロジック
        let pattern = #"\\(\d{1,3})"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
        
        var result = inputText
        let matches = regex.matches(in: inputText, range: NSRange(inputText.startIndex..., in: inputText))
        
        for match in matches.reversed() {
            if let range = Range(match.range(at: 1), in: inputText),
               let code = UInt8(inputText[range]),
               let charRange = Range(match.range, in: result) {
                let char = String(UnicodeScalar(code))
                result.replaceSubrange(charRange, with: char)
            }
        }
        
        // MoonSec特有のゴミ（長いコメント）を削除
        result = result.replacingOccurrences(of: #"--\[\[.*\]\]"#, with: "", options: .regularExpression)
        
        self.outputText = result
    }
}
