import Fluent
import Vapor
import Foundation
import EventKit

struct UserModel: Content {
    let id: String?
    let email: String
    let secret: String
}

struct ClientValues: Content {
    var email: String
    var code: String
}

struct ResultModel: Content {
    var value: Bool
}

struct UserController: RouteCollection {
    let totpModel = Totp()

    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.get(use: index)
        users.post(use: create)
        users.group(":userID") { user in
            user.delete(use: delete)
        }
    }

    func index(req: Request) throws -> EventLoopFuture<[User]> {
        return User.query(on: req.db).all()
    }

    func getUser(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)

        return User.query(on: req.db)
            .filter(\.$email == user.email)
            .first() ?? User()
    }

    func removeUser(req: Request) throws -> EventLoopFuture<User> {
        let user = try req.content.decode(User.self)
        return User.query(on: req.db)
            .filter(\.$email == user.email)
            .delete()
            .transform(to: user)
    }

    func create(req: Request) throws -> EventLoopFuture<User> {
        let reqUser = try req.content.decode(UserModel.self)
        let user = User(id: nil, email: reqUser.email, secret: reqUser.secret)
        return user.save(on: req.db).map { user }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        return User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { $0.delete(on: req.db) }
            .transform(to: .ok)
    }

    func checkTotp(req: Request) throws -> EventLoopFuture<ResultModel> {
        let clientValues = try req.content.decode(ClientValues.self)
        let eventLoopUser = User.query(on: req.db)
            .filter(\.$email == clientValues.email)
            .first()

        return eventLoopUser.map { user -> ResultModel in
            guard let user = user else {
                return ResultModel(value: false)
            }

            return ResultModel(value: totpModel.checkTotp(clientCode: clientValues.code, user: user))
        }
    }
}
