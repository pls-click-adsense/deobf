import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var inputText = ""
    @State private var outputText = ""
    @State private var showFileImporter = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 入力セクション
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Encoded Lua").font(.subheadline).bold()
                        Spacer()
                        
                        // 【新機能】クリップボードから貼り付けボタン
                        Button(action: pasteFromClipboard) {
                            Label("Paste", systemImage: "doc.on.clipboard")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        
                        // 【新機能】ファイルを選択ボタン
                        Button(action: { showFileImporter = true }) {
                            Label("File", systemImage: "folder")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.orange)
                    }
                    
                    TextEditor(text: $inputText)
                        .frame(height: 250)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2)))
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                }
                
                // 変換ボタン（目立たせる）
                Button(action: deobfuscate) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Deobfuscate (MoonSec)")
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 3)
                }
                .padding(.horizontal)

                // 出力セクション
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Result").font(.subheadline).bold()
                        Spacer()
                        
                        // コピーボタン
                        Button(action: copyToClipboard) {
                            Label("Copy", systemImage: "doc.on.doc")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }
                    
                    TextEditor(text: $outputText)
                        .frame(height: 250)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.2)))
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Lua Deobf V1")
            
            // ファイル選択画面のポップアップ
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.text, .plainText, UTType(filenameExtension: "lua")!], allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        if url.startAccessingSecurityScopedResource() {
                            defer { url.stopAccessingSecurityScopedResource() }
                            if let content = try? String(contentsOf: url) {
                                self.inputText = content
                            }
                        }
                    }
                case .failure(let error):
                    print("Error selecting file: \(error.localizedDescription)")
                }
            }
        }
    }

    // --- ロジック部分 ---

    func pasteFromClipboard() {
        if let pasteboardString = UIPasteboard.general.string {
            self.inputText = pasteboardString
        }
    }

    func copyToClipboard() {
        UIPasteboard.general.string = outputText
    }

    func deobfuscate() {
        // \数字 形式をデコード
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
