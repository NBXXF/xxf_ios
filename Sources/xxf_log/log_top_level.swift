import Foundation

public func logD(_ message: () -> String,
          tag: String = "General",
          file: String = #fileID,
          function: String = #function,
          line: Int = #line) {
    LogUtils.debug("[\(tag)] [\(file):\(line) \(function)] \(message())")
}



public func logI(_ message: () -> String,
          tag: String = "General",
          file: String = #fileID,
          function: String = #function,
          line: Int = #line) {
    LogUtils.info("[\(tag)] [\(file):\(line) \(function)] \(message())")
}





public func logW(_ message: () -> String,
          tag: String = "General",
          file: String = #fileID,
          function: String = #function,
          line: Int = #line) {
    LogUtils.warning("[\(tag)] [\(file):\(line) \(function)] \(message())")
}




public func logE(_ message:  () -> String,
          tag: String = "General",
          file: String = #fileID,
          function: String = #function,
          line: Int = #line) {
    LogUtils.error("[\(tag)] [\(file):\(line) \(function)] \(message())")
}
