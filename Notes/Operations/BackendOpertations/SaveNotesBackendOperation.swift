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
        guard let url = URL(string: baseUrlStr) else {
            result = .failure(.unreachable)
            finish()
            return
        }
        if let gistId = UserDefaults().string(forKey: "gist_id") {
            executeSaveTask(url, token, gistId)
        } else {
            executeCheckGistTask(url, token)
        }
    }
    
    // Проверка наличия гиста и файла на гитхабе и запускает запись.
    private func executeCheckGistTask(_ url: URL, _ token: String) {
        var request = URLRequest(url: url)
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
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
            guard let gists = try? JSONDecoder().decode([Gist].self, from: data) else {
                self?.result = .failure(.unreachable)
                self?.finish()
                return
            }
            guard let this = self else {
                self?.result = .failure(.unreachable)
                self?.finish()
                return
            }
            let gistId = gists.filter { gist in gist.files.keys.contains(this.fileName)}.first?.id
            this.executeSaveTask(url, token, gistId)
            }.resume()
    }
    
    // Запись данных в гист. Если есть ид, обновляет. Иначе, создает.
    private func executeSaveTask(_ url: URL, _ token: String, _ gistId: String?) {
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
        // Если есть ид гиста, обновляет гист. Иначе, создает гист.
        if gistId != nil {
            UserDefaults().set(gistId, forKey: "gist_id")
            request = URLRequest(url: url.appendingPathComponent(gistId!))
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
                if response.statusCode == 404 {
                    UserDefaults().set(nil, forKey: "gist_id")
                    self?.executeCheckGistTask(url, token)
                } else {
                    self?.result = .failure(.unreachable)
                    self?.finish()
                }
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
            if response.statusCode == 201 {
                UserDefaults().set(gist.id, forKey: "gist_id")
            }
            self?.result = .success(Void())
            self?.finish()
            }.resume()
    }
}
