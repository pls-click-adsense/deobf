import SwiftUI

struct ContentView: View {
    @State private var inputText = ""
    @State private var outputText = ""

    var body: some View {
        VStack(spacing: 10) {
            Text("WRD VM Decoder v2.0")
                .font(.headline)
                .padding(.top)

            HStack {
                Text("Input")
                Spacer()
                Button("Paste") {
                    if let string = UIPasteboard.general.string { inputText = string }
                }
                .buttonStyle(.borderedProminent).controlSize(.small)
            }
            .padding(.horizontal)

            TextEditor(text: $inputText)
                .frame(height: 180)
                .border(Color.gray.opacity(0.5), width: 1)
                .cornerRadius(5)
                .padding(.horizontal)

            Button(action: deobfuscate) {
                Text("DECODE VM (BETA)")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            HStack {
                Text("Result")
                Spacer()
                Button("Copy") { UIPasteboard.general.string = outputText }
                .buttonStyle(.borderedProminent).controlSize(.small).tint(.green)
            }
            .padding(.horizontal)

            TextEditor(text: $outputText)
                .frame(height: 180)
                .border(Color.red.opacity(0.5), width: 1)
                .cornerRadius(5)
                .padding(.horizontal)

            Spacer()
        }
        .background(Color.white)
    }

    func deobfuscate() {
        var result = inputText
        
        let mathPattern = #"(-?\d+)\s*([-+*/])\s*(-?\d+|\(-?\d+\))"#
        if let regex = try? NSRegularExpression(pattern: mathPattern) {
            var previous = ""
            while previous != result {
                previous = result
                let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
                for match in matches.reversed() {
                    if let range = Range(match.range, in: result) {
                        let expressionStr = String(result[range]).replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
                        let expr = NSExpression(format: expressionStr)
                        if let mathResult = expr.expressionValue(with: nil, context: nil) as? NSNumber {
                            result.replaceSubrange(range, with: "\(mathResult.intValue)")
                        }
                    }
                }
            }
        }

        let charPattern = #"\\(\d{1,3})"#
        if let regex = try? NSRegularExpression(pattern: charPattern) {
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

        result = result.replacingOccurrences(of: #""\s*\.\.\s*""#, with: "", options: .regularExpression)

        result = result.replacingOccurrences(of: #"--\[\[.*?\]\]"#, with: "", options: .regularExpression)
        
        self.outputText = result
    }
}
