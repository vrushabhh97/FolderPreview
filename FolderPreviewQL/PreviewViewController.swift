// PreviewViewController.swift in the Quick Look Extension
import Cocoa
import Quartz

class PreviewViewController: NSViewController, QLPreviewingController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    private var folderURL: URL?
    private var folderContents: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup collection view
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        // Configure collection view layout
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 120, height: 120)
        flowLayout.sectionInset = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        
        collectionView.collectionViewLayout = flowLayout
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register cell class
        collectionView.register(ItemCell.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("ItemCell"))
        
        // Set background
        collectionView.backgroundColors = [NSColor.windowBackgroundColor]
    }
    
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        // Check if this is a directory
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            handler(NSError(domain: "FolderPreviewErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not a folder"]))
            return
        }
        
        self.folderURL = url
        
        // Get folder contents
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey, .fileSizeKey], options: [.skipsHiddenFiles])
            self.folderContents = contents.sorted { $0.lastPathComponent < $1.lastPathComponent }
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
            handler(nil)
        } catch {
            handler(error)
        }
    }
}

// MARK: - NSCollectionViewDataSource
extension PreviewViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return folderContents.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ItemCell"), for: indexPath)
        
        guard let cell = item as? ItemCell else { return item }
        
        let fileURL = folderContents[indexPath.item]
        cell.configure(with: fileURL)
        
        return cell
    }
}

// MARK: - NSCollectionViewDelegate
extension PreviewViewController: NSCollectionViewDelegate {
    // Handle item selection if needed
}
