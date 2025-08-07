import Amplify
import Foundation

func addToGroup(username: String, groupName: String) async {
    let path = "/addUserToGroup"
    let body = "{\"username\":\"\(username)\",\"groupname\":\"\(groupName)\"}".data(using: .utf8)
    let request = RESTRequest(path: path, body: body)
    do {
        let data = try await Amplify.API.post(request: request)
        print("✅ User added to group. Response Body: \(String(decoding: data, as: UTF8.self))")
    } catch {
        if case let .httpStatusError(statusCode, response) = error as? APIError {
            print("❌ HTTP Error StatusCode: \(statusCode)")
            print("❌ Response: \(response)")
        } else {
            print("❌ Error adding user to group: \(error)")
        }
    }
}

func listUsersInGroup(groupName: String, limit: Int, nextToken: String? = nil) async {
    let path = "/listUsersInGroup"
    var query = [
        "groupname": groupName,
        "limit": String(limit)
    ]
    if let nextToken = nextToken {
        query["token"] = nextToken
    }
    let request = RESTRequest(path: path, queryParameters: query, body: nil)
    do {
        let data = try await Amplify.API.get(request: request)
        print("✅ Users in group: \(String(decoding: data, as: UTF8.self))")
    } catch {
        if case let .httpStatusError(statusCode, response) = error as? APIError {
            print("❌ HTTP Error StatusCode: \(statusCode)")
            print("❌ Response: \(response)")
        } else {
            print("❌ Error listing users in group: \(error)")
        }
    }
}
