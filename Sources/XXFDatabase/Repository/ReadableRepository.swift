//
//  BaseRepository.swift
//  xxf_ios
//  只读的数据库层
//  Created by xxf on 6/3.
//
public protocol ReadableRepository {
    associatedtype PK
    associatedtype Entity
    associatedtype Query

    func selectById(_ id: PK) -> Entity?
    func selectByIds(_ ids: [PK]) -> [Entity]
    func selectAll() -> [Entity]

    func selectOne(where block: (Query) -> Query) throws -> Entity?
    func selectFirst(where block: (Query) -> Query) -> Entity?
    func selectList(where block: (Query) -> Query) -> [Entity]
    func selectPage(page: Int, pageSize: Int, where block: (Query) -> Query) -> BasePageInfoDTO<Entity>
    func count(where block: (Query) -> Query) -> Int
    func contains(where block: (Query) -> Query) -> Bool
}
