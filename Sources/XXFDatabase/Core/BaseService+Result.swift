//
//  BaseService+Result.swift
//  xxf_ios
//  增加安全性包裹
//  Created by xxfon 2025/6/4.
//

public extension BaseService {
    /// 包装安全性处理,建议自定义方法都加上这个,可以用于崩溃处理和全局监听错误或者上报日志
    func runOperation<T>(
        _ operation: () throws -> T?,
        errorConsumer: ((Error) -> Void)? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) -> Result<T, Error> where T: Any {
        do {
//            let result = try operation()
//            return .success(result)

            if let result = try operation() {
                return .success(result)
            } else {
                return .failure(DatabaseNoDataError())
            }
        } catch {
            let wrappedError: Error
            if let dbError = error as? DatabaseOperationError {
                wrappedError = dbError
            } else {
                wrappedError = DatabaseOperationError(
                    underlyingError: error,
                    file: file,
                    function: function,
                    line: line
                )
            }
            errorConsumer?(wrappedError)
            return .failure(wrappedError)
        }
    }
}
