import Foundation
import CocoaLumberjack

class LoadNotesBackendOperation: BaseBackendOperation {
    var result: Result<[Note], NetworkError>?
    
    override func main() {
        DDLogInfo("LoadNotesBackendOperations execution")
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
            executeLoadGistTask(url, token, gistId)
        } else {
            executeCheckGistTask(url, token)
        }
    }
    
    // Проверка наличия гиста и файла на гитхабе. Если есть, запускает загрузку.
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
            if gistId == nil {
                self?.result = .failure(.unreachable)
                self?.finish()
                return
            }
            this.executeLoadGistTask(url, token, gistId!)
            }.resume()
    }
    
    // Загрузка данных из гиста
    private func executeLoadGistTask(_ url: URL, _ token: String, _ gistId: String) {
        UserDefaults().set(gistId, forKey: "gist_id")
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
            var notes = [Note]()
            if let this = self, let content = gist.files[this.fileName]?.content?.data(using: .utf8) {
                guard let items = try? JSONSerialization.jsonObject(with: content, options: []) as? [[String: Any]] else {
                    self?.result = .failure(.unreachable)
                    self?.finish()
                    return
                }
                items.forEach {item in
                    switch Note.parse(json: item) {
                    case let note?: notes.append(note)
                    default: break
                    }
                }
            }
            self?.result = .success(notes)
            self?.finish()
            }.resume()
    }
}
