// RouterSpec.swift
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Nimble
import Quick
import Auth0

@testable import Lock

class RouterSpec: QuickSpec {

    override func spec() {

        var lock: Lock!
        var controller: UIViewController!
        var router: Router!

        beforeEach {
            lock = Lock(authentication: Auth0.authentication(clientId: "CLIENT_ID", domain: "samples.auth0.com"))
            controller = MockController()
            router = Router(lock: lock, controller: controller)
        }

        describe("root") {

            it("should return no root if there are no connections") {
                lock.connections = nil
                expect(router.root).to(beNil())
            }

            it("should return root for single database connection") {
                var connections: ConnectionBuildable = OfflineConnections()
                connections.database(name: connection, requiresUsername: true)
                lock.connections = connections
                expect(router.root).toNot(beNil())
            }

        }

        describe("events") {

            it("should call callback with auth result") {
                let credentials = Credentials(accessToken: "ACCESS_TOKEN", tokenType: "bearer")
                waitUntil(timeout: 2) { done in
                    lock.callback = { result in
                        if case .Success(let actual) = result {
                            expect(actual) == credentials
                            done()
                        }
                    }
                    router.onAuthentication(credentials)
                }
            }
        }
    }

}

class MockController: UIViewController {
    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        completion?()
    }
}