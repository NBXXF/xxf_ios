import Foundation

func logD(_ message: () -> String,
          tag: String = "General",
          file: String = #fileID,
          function: String = #function,
          line: Int = #line) {
    LogUtils.debug("[\(tag)] [\(file):\(line) \(function)] \(message())")
}



func logI(_ message: () -> String,
          tag: String = "General",
          file: String = #fileID,
          function: String = #function,
          line: Int = #line) {
    LogUtils.info("[\(tag)] [\(file):\(line) \(function)] \(message())")
}





func logW(_ message: () -> String,
          tag: String = "General",
          file: String = #fileID,
          function: String = #function,
          line: Int = #line) {
    LogUtils.warning("[\(tag)] [\(file):\(line) \(function)] \(message())")
}




func logE(_ message:  () -> String,
          tag: String = "General",
          file: String = #fileID,
          function: String = #function,
          line: Int = #line) {
    LogUtils.error("[\(tag)] [\(file):\(line) \(function)] \(message())")
}
