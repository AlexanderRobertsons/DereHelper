import Foundation
import CoreData
public final class ManagedObjectObserver {
    public enum ChangeType {
        case delete
        case update
    }
    public init?(object: Managed, changeHandler: @escaping (ChangeType) -> ()) {
        guard let moc = object.managedObjectContext else { return nil }
        objectHasBeenDeleted = !type(of: object).defaultPredicate.evaluate(with: object)
        token = moc.addObjectsDidChangeNotificationObserver { [weak self] note in
            guard let changeType = self?.changeType(of: object, in: note) else { return }
            self?.objectHasBeenDeleted = changeType == .delete
            changeHandler(changeType)
        }
    }
    fileprivate var token: NSObjectProtocol!
    fileprivate var objectHasBeenDeleted: Bool = false
    fileprivate func changeType(of object: Managed, in note: ObjectsDidChangeNotification) -> ChangeType? {
        let deleted = note.deletedObjects.union(note.invalidatedObjects)
        if note.invalidatedAllObjects || deleted.containsObjectIdentical(to: object) {
            return .delete
        }
        let updated = note.updatedObjects.union(note.refreshedObjects)
        if updated.containsObjectIdentical(to: object) {
            let predicate = type(of: object).defaultPredicate
            if predicate.evaluate(with: object) {
                return .update
            } else if !objectHasBeenDeleted {
                return .delete
            }
        }
        return nil
    }
}
