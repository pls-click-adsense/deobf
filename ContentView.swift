import SwiftUI

struct ContentView: View {
    @State private var inputText = ""
    @State private var outputText = ""

    var body: some View {
        VStack(spacing: 10) {
            Text("MoonSec Deobf v1.2")
                .font(.headline)
                .padding(.top)

            // --- 入力エリア ---
            HStack {
                Text("Input").font(.caption).bold()
                Spacer()
                // 貼り付けボタン
                Button("Paste") {
                    if let string = UIPasteboard.general.string {
                        inputText = string
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            .padding(.horizontal)

            TextEditor(text: $inputText)
                .frame(height: 180)
                .border(Color.gray.opacity(0.5), width: 1)
                .cornerRadius(5)
                .padding(.horizontal)

            // --- メイン変換ボタン ---
            Button(action: deobfuscate) {
                Text("RUN DEOBFUSCATE")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // --- 出力エリア ---
            HStack {
                Text("Result").font(.caption).bold()
                Spacer()
                // コピーボタン
                Button("Copy") {
                    UIPasteboard.general.string = outputText
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .tint(.green)
            }
            .padding(.horizontal)

            TextEditor(text: $outputText)
                .frame(height: 180)
                .border(Color.blue.opacity(0.5), width: 1)
                .cornerRadius(5)
                .padding(.horizontal)

            Spacer()
        }
        .background(Color.white)
    }

    func deobfuscate() {
        var result = inputText
        
        // 1. \数字 形式を復元
        let pattern = #"\\(\d{1,3})"#
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
            for match in matches.reversed() {
                if let range = Range(match.range(at: 1), in: result),
                   let code = UInt8(result[range]),
                   let charRange = Range(match.range, in: result) {
                    let char = String(UnicodeScalar(code))
                    result.replaceSubrange(charRange, with: char)
                }
            }
        }
        
        // 2. ゴミ削り
        result = result.replacingOccurrences(of: #"--\[\[.*\]\]"#, with: "", options: .regularExpression)
        
        self.outputText = result
    }
}
