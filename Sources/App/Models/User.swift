import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: "id")
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "secret")
    var secret: String?

    init() { }

    init(id: UUID? = nil, email: String, secret: String) {
        self.id = id
        self.email = email
        self.secret = secret
    }
}
