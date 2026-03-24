//
//  ThumbnailOptions.swift
//  xxf_ios
//
//  Created by xxf
//
/// 缩略图参数配置枚举（替代原结构体）
public enum ThumbnailOptions {
    /// 自定义宽高 + 质量（全参数）
    case custom(w: Int? = nil, h: Int? = nil, q: Int? = nil)
    /// 仅指定宽度（高度自适应，质量默认）
    case width(Int)
    /// 仅指定高度（宽度自适应，质量默认）
    case height(Int)
    /// 仅指定质量（宽高默认）
    case quality(Int)
    /// 固定宽高（质量默认）
    case size(w: Int, h: Int)
    
    // 直接获取原结构体的所有属性
    public var w: Int? {
        switch self {
        case .custom(let w, _, _): return w
        case .width(let w): return w
        case .height: return nil
        case .quality: return nil
        case .size(let w, _): return w
        }
    }
    
    public var h: Int? {
        switch self {
        case .custom(_, let h, _): return h
        case .width: return nil
        case .height(let h): return h
        case .quality: return nil
        case .size(_, let h): return h
        }
    }
    
    public var q: Int? {
        switch self {
        case .custom(_, _, let q): return q
        case .width, .height, .size: return nil
        case .quality(let q): return q
        }
    }
}
