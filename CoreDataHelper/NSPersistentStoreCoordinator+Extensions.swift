import CoreData
extension NSPersistentStoreCoordinator {
    public static func destroyStore(at url: URL) {
        do {
            let psc = self.init(managedObjectModel: NSManagedObjectModel())
            try psc.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType, options: nil)
        } catch let e {
            print("failed to destroy persistent store at \(url)", e)
        }
    }
    public static func replaceStore(at targetURL: URL, withStoreAt sourceURL: URL) throws {
        let psc = self.init(managedObjectModel: NSManagedObjectModel())
        try psc.replacePersistentStore(at: targetURL, destinationOptions: nil, withPersistentStoreFrom: sourceURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
    }
}
