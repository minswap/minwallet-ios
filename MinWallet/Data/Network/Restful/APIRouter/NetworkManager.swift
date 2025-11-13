import Alamofire

final class NetworkManager {
    static let shared = NetworkManager()
    
    let session: Session
    
    private init() {
        /*TODO: update cer with command
        openssl s_client -connect ios-api.minswap.org:443 -showcerts < /dev/null \
        | openssl x509 -outform DER > ios-api.cer
         */
        let evaluators: [String: ServerTrustEvaluating] = [
            "ios-api.minswap.org": PublicKeysTrustEvaluator(
                performDefaultValidation: true,
                validateHost: true
            )
        ]
        
        let serverTrustManager = ServerTrustManager(
            allHostsMustBeEvaluated: true,
            evaluators: evaluators
        )
        
        session = Session(serverTrustManager: serverTrustManager)
    }
}
