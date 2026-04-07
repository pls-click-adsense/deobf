import SwiftUI

struct ContentView: View {
    @State private var inputText = ""
    @State private var outputText = ""

    var body: some View {
        VStack(spacing: 15) {
            Text("MoonSec Deobfuscator")
                .font(.title2)
                .bold()
                .padding(.top)

            // 入力エリア
            VStack(alignment: .leading) {
                Text("Encoded Lua:").font(.caption).foregroundColor(.gray)
                TextEditor(text: $inputText)
                    .frame(height: 200)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
            }

            // 変換ボタン
            Button(action: deobfuscate) {
                Text("Deobfuscate ✨")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }

            // 出力エリア
            VStack(alignment: .leading) {
                Text("Result:").font(.caption).foregroundColor(.gray)
                TextEditor(text: $outputText)
                    .frame(height: 200)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.green.opacity(0.3)))
            }

            Button("Copy to Clipboard") {
                UIPasteboard.general.string = outputText
            }
            .padding(.bottom)
        }
        .padding()
    }

    func deobfuscate() {
        // \104 形式を文字に戻す
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
        
        // ゴミ（コメント等）の簡易削除
        result = result.replacingOccurrences(of: #"--\[\[.*?\]\]"#, with: "", options: .regularExpression)
        
        self.outputText = result
    }
}
