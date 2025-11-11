import Testing
@testable import XXFLog

@Test func example() async throws {
    tryOrLog {}
    tryOrNil {}
    tryOrFalse {}
    tryOrLogNil {}
    tryOrLogFalse {}
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}
