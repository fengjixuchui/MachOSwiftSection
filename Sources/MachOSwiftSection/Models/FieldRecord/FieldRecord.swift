import Foundation
import MachOKit
import MachOMacro
import MachOFoundation

public struct FieldRecord: ResolvableLocatableLayoutWrapper {
    public struct Layout: Sendable {
        public let flags: FieldRecordFlags
        public let mangledTypeName: RelativeDirectPointer<MangledName>
        public let fieldName: RelativeDirectPointer<String>
    }

    public let offset: Int

    public var layout: Layout

    public init(layout: Layout, offset: Int) {
        self.offset = offset
        self.layout = layout
    }
}

@MachOImageAllMembersGenerator
extension FieldRecord {
    public func mangledTypeName(in machOFile: MachOFile) throws -> MangledName {
        return try layout.mangledTypeName.resolve(from: offset(of: \.mangledTypeName), in: machOFile)
    }

    public func fieldName(in machOFile: MachOFile) throws -> String {
        return try layout.fieldName.resolve(from: offset(of: \.fieldName), in: machOFile)
    }
}
