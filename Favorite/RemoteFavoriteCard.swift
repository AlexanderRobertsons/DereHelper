import UIKit
import CoreData
import CloudKit
struct RemoteFavoriteCard: RemoteRecord {
    var id: String
    var creatorID: String
    var cardID: Int64
    var localCreatedAt: Date
}
extension RemoteFavoriteCard {
    static var recordType: String { return "FavoriteCard" }
    init?(record: CKRecord) {
        guard record.recordType == RemoteFavoriteCard.recordType else { return nil }
        guard
            let localCreatedAt = record["localCreatedAt"] as? Date,
            let cardID = record["cardID"] as? NSNumber,
            let creatorID = record.creatorUserRecordID?.recordName else {
                return nil
        }
        self.id = record.recordID.recordName
        self.creatorID = creatorID
        self.localCreatedAt = localCreatedAt
        self.cardID = cardID.int64Value
    }
}
extension RemoteFavoriteCard {
    func insert(into context: NSManagedObjectContext, completion: @escaping (Bool) -> ()) {
        context.perform {
            let card = FavoriteCard.insert(into: context, cardID: Int(self.cardID))
            card.creatorID = self.creatorID
            card.remoteIdentifier = self.id
            card.createdAt = self.localCreatedAt
            completion(true)
        }
    }
}
