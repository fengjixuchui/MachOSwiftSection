import Foundation
import MachOKit
import MachOMacro
import MachOFoundation

// template <typename Runtime>
// class swift_ptrauth_struct_context_descriptor(EnumDescriptor)
//    TargetEnumDescriptor final
//    : public TargetValueTypeDescriptor<Runtime>,
//      public TrailingGenericContextObjects<TargetEnumDescriptor<Runtime>,
//                            TargetTypeGenericContextDescriptorHeader,
//                            additional trailing objects
//                            TargetForeignMetadataInitialization<Runtime>,
//                            TargetSingletonMetadataInitialization<Runtime>,
//                            TargetCanonicalSpecializedMetadatasListCount<Runtime>,
//                            TargetCanonicalSpecializedMetadatasListEntry<Runtime>,
//                            TargetCanonicalSpecializedMetadatasCachingOnceToken<Runtime>,
//                            InvertibleProtocolSet,
//                            TargetSingletonMetadataPointer<Runtime>>

@dynamicMemberLookup
public struct Enum {
    public let descriptor: EnumDescriptor
    public let genericContext: TypeGenericContext?
    public let foreignMetadataInitialization: ForeignMetadataInitialization?
    public let singletonMetadataInitialization: SingletonMetadataInitialization?
    public let canonicalSpecializedMetadatas: [CanonicalSpecializedMetadatasListEntry]
    public let canonicalSpecializedMetadatasListCount: CanonicalSpecializedMetadatasListCount?
    public let canonicalSpecializedMetadatasCachingOnceToken: CanonicalSpecializedMetadatasCachingOnceToken?
    public let invertibleProtocolSet: InvertibleProtocolSet?
    public let singletonMetadataPointer: SingletonMetadataPointer?

    @MachOImageGenerator
    public init(descriptor: EnumDescriptor, in machOFile: MachOFile) throws {
        self.descriptor = descriptor

        var currentOffset = descriptor.offset + descriptor.layoutSize

        let genericContext = try descriptor.typeGenericContext(in: machOFile)

        if let genericContext {
            currentOffset += genericContext.size
        }

        self.genericContext = genericContext

        let typeFlags = try required(descriptor.flags.kindSpecificFlags?.typeFlags)

        if typeFlags.hasForeignMetadataInitialization {
            self.foreignMetadataInitialization = try machOFile.readElement(offset: currentOffset)
            currentOffset.offset(of: ForeignMetadataInitialization.self)
        } else {
            self.foreignMetadataInitialization = nil
        }

        if typeFlags.hasSingletonMetadataInitialization {
            self.singletonMetadataInitialization = try machOFile.readElement(offset: currentOffset)
            currentOffset.offset(of: SingletonMetadataInitialization.self)
        } else {
            self.singletonMetadataInitialization = nil
        }

        if descriptor.hasCanonicalMetadataPrespecializations {
            let count: CanonicalSpecializedMetadatasListCount = try machOFile.readElement(offset: currentOffset)
            currentOffset.offset(of: CanonicalSpecializedMetadatasListCount.self)
            let countValue = count.rawValue
            let canonicalMetadataPrespecializations: [CanonicalSpecializedMetadatasListEntry] = try machOFile.readElements(offset: currentOffset, numberOfElements: countValue.cast())
            currentOffset.offset(of: CanonicalSpecializedMetadatasListEntry.self, numbersOfElements: countValue.cast())
            self.canonicalSpecializedMetadatas = canonicalMetadataPrespecializations
            self.canonicalSpecializedMetadatasListCount = count
            self.canonicalSpecializedMetadatasCachingOnceToken = try machOFile.readElement(offset: currentOffset)
            currentOffset.offset(of: CanonicalSpecializedMetadatasCachingOnceToken.self)
        } else {
            self.canonicalSpecializedMetadatas = []
            self.canonicalSpecializedMetadatasListCount = nil
            self.canonicalSpecializedMetadatasCachingOnceToken = nil
        }

        if descriptor.flags.hasInvertibleProtocols {
            self.invertibleProtocolSet = try machOFile.readElement(offset: currentOffset)
            currentOffset.offset(of: InvertibleProtocolSet.self)
        } else {
            self.invertibleProtocolSet = nil
        }

        if descriptor.hasSingletonMetadataPointer {
            self.singletonMetadataPointer = try machOFile.readElement(offset: currentOffset)
            currentOffset.offset(of: SingletonMetadataPointer.self)
        } else {
            self.singletonMetadataPointer = nil
        }
    }

    public subscript<T>(dynamicMember member: KeyPath<EnumDescriptor, T>) -> T {
        return descriptor[keyPath: member]
    }
}


