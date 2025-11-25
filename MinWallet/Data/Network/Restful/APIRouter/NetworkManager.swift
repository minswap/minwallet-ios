import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    
    let session: Session
    
    private init() {
        session = .default
    }
}
