import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    let userController = UserController()

    app.get("data") { req -> EventLoopFuture<[User]> in
        return try userController.index(req: req)
    }

    app.post("addUser") { req -> EventLoopFuture<User> in
        return try userController.create(req: req)
    }

    app.get("getUser") {req -> EventLoopFuture<User> in
        return try userController.getUser(req: req)
    }

    app.post("removeUser") { req -> EventLoopFuture<User> in
        return try userController.removeUser(req: req)
    }

    app.post("checkTotp") { req -> EventLoopFuture<ResultModel> in
        return try userController.checkTotp(req: req)
    }

    try app.register(collection: UserController())
}
