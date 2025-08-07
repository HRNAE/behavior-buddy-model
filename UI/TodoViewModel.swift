//
//  TodoViewModel.swift
//  Behavior Buddy
//
//  Created by Micah Pressler on 11/9/24.
//

import Foundation
import Amplify

@MainActor
class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    private var subscription: AmplifyAsyncThrowingSequence<GraphQLSubscriptionEvent<Todo>>

    init() {
       self.subscription = Amplify.API.subscribe(request: .subscription(of: Todo.self, type: .onCreate))
    }

    func subscribe() {
        Task {
            do {
                for try await subscriptionEvent in subscription {
                    handleSubscriptionEvent(subscriptionEvent)
                }
            } catch {
                print("Subscription has terminated with \(error)")
            }
        }
    }

    private func handleSubscriptionEvent(_ subscriptionEvent: GraphQLSubscriptionEvent<Todo>) {
        switch subscriptionEvent {
        case .connection(let subscriptionConnectionState):
            print("Subscription connect state is \(subscriptionConnectionState)")
        case .data(let result):
            switch result {
            case .success(let createdTodo):
                print("Successfully got todo from subscription: \(createdTodo)")
                todos.append(createdTodo)
            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
            }
        }
    }

    func cancel() {
        self.subscription.cancel()
    }
    
    func createTodo() {
        var todo = Todo(
            content: "Build iOS Application",
            isDone: false
        )
        Task {
            do {
                let result = try await Amplify.API.mutate(request: .create(todo))
                switch result {
                case .success(let todo):
                    print("Successfully created todo: \(todo)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            } catch let error as APIError {
                print("Failed to create todo: ", error)
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }
    
    func deleteTodo() {
        var todo = Todo(
            content: "Build iOS Application",
            isDone: false
        )
        Task {
            do {
                let result = try await Amplify.API.mutate(request: .delete(todo))
                switch result {
                case .success(let todo):
                    print("Successfully deleted todo: \(todo)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            } catch let error as APIError {
                print("Failed to delete todo: ", error)
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }
    
    func listTodos() {
        Task {
            do {
                let result = try await Amplify.API.query(request: .list(Todo.self))
                switch result {
                case .success(let todos):
                    print("Successfully retrieved list of todos: \(todos)")
                    self.todos = todos.elements
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            } catch let error as APIError {
                print("Failed to query list of todos: ", error)
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }
}
