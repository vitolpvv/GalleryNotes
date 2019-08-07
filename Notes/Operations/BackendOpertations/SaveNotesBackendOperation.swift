import Foundation
import CocoaLumberjack

class SaveNotesBackendOperation: BaseBackendOperation {
    var result: Result<Void, NetworkError>?
    let notesProvider: NotesProvider
    
    init(notesProvider: NotesProvider) {
        self.notesProvider = notesProvider
        super.init()
    }
    
    override func main() {
        DDLogInfo("SaveNotesBackendOperation execution")
        
        guard let token = UserDefaults().string(forKey: "token") else {
            result = .failure(.unreachable)
            finish()
            return
        }
        guard var url = URL(string: baseUrlStr) else {
            result = .failure(.unreachable)
            finish()
            return
        }
        var items = [[String: Any]]()
        notesProvider.notes.forEach { note in
            items.append(note.json)
        }
        guard let jsonNotes = try? JSONSerialization.data(withJSONObject: items, options: []) else {
            result = .failure(.unreachable)
            finish()
            return
        }
        guard let content = String(data: jsonNotes, encoding: .utf8) else {
            result = .failure(.unreachable)
            finish()
            return
        }
        let gist = Gist(id: nil, description: gistDescription, files: [fileName : GistFile(content: content)])
        guard let json = try? JSONEncoder().encode(gist) else {
            result = .failure(.unreachable)
            finish()
            return
        }
        var request: URLRequest
        // Если в базе есть ид гиста, обновляет гист. Иначе создает гист.
        if let gistId = UserDefaults().string(forKey: "gist_id") {
            url = url.appendingPathComponent(gistId)
            request = URLRequest(url: url)
            request.httpMethod = "PATCH"
        } else {
            request = URLRequest(url: url)
            request.httpMethod = "POST"
        }
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = json
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard error == nil else {
                self?.result = .failure(.unreachable)
                self?.finish()
                return
            }
            guard let response = response as? HTTPURLResponse else {
                self?.result = .failure(.unreachable)
                self?.finish()
                return
            }
            guard (200..<300).contains(response.statusCode) else {
                self?.result = .failure(.unreachable)
                self?.finish()
                return
            }
            guard let data = data else {
                self?.result = .failure(.unreachable)
                self?.finish()
                return
            }
            guard let gist = try? JSONDecoder().decode(Gist.self, from: data) else {
                self?.result = .failure(.unreachable)
                self?.finish()
                return
            }
            // Если гист создан, сохраняет ид в базу
            if response.statusCode == 201 {
                UserDefaults().setValue(gist.id, forKey: "gist_id")
            }
            self?.result = .success(Void())
            self?.finish()
        }.resume()
    }
}
