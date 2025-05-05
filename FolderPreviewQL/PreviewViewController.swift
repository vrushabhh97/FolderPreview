import Cocoa
import Quartz
import ZIPFoundation

class PreviewViewController: NSViewController, QLPreviewingController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    
    private var folderURL: URL?
    private var folderContents: [URL] = []
    private var zipEntries: [ZipEntry] = []
    private var isZipFile: Bool = false
    
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
        
        // Register cell classes
        collectionView.register(ItemCell.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("ItemCell"))
        collectionView.register(ZipItemCell.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("ZipItemCell"))
        
        // Set background
        collectionView.backgroundColors = [NSColor.windowBackgroundColor]
    }
    
    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        // Check if it's a ZIP file
        if url.pathExtension.lowercased() == "zip" {
            // Handle ZIP preview
            loadZipPreview(from: url)
            handler(nil)
            return
        }
        
        // Check if this is a directory
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            handler(NSError(domain: "FolderPreviewErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Not a folder"]))
            return
        }
        
        self.folderURL = url
        self.isZipFile = false
        
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
    
    // New method to handle ZIP file previews
    private func loadZipPreview(from url: URL) {
        self.folderURL = url
        self.isZipFile = true
        self.zipEntries.removeAll()
        
        guard let archive = Archive(url: url, accessMode: .read) else {
            print("Error: Unable to open ZIP archive")
            return
        }
        
        // Extract entries from ZIP file
        for entry in archive {
            let isDirectory = entry.path.hasSuffix("/")
            let path = entry.path
            
            // Create icon based on file type
            let fileExtension = URL(fileURLWithPath: path).pathExtension
            let icon: NSImage
            
            if isDirectory {
                icon = NSWorkspace.shared.icon(forFileType: NSFileTypeForHFSTypeCode(UInt32(kGenericFolderIcon)))
            } else {
                icon = NSWorkspace.shared.icon(forFileType: fileExtension)
            }
            
            // Create ZIP entry
            let zipEntry = ZipEntry(
                name: URL(fileURLWithPath: isDirectory ? String(path.dropLast()) : path).lastPathComponent,
                path: path,
                isDirectory: isDirectory,
                size: entry.uncompressedSize,
                modificationDate: entry.fileAttributes[.modificationDate] as? Date,
                icon: icon
            )
            
            zipEntries.append(zipEntry)
        }
        
        // Sort entries
        zipEntries.sort { (entry1, entry2) -> Bool in
            // Directories first, then alphabetical
            if entry1.isDirectory && !entry2.isDirectory {
                return true
            } else if !entry1.isDirectory && entry2.isDirectory {
                return false
            } else {
                return entry1.name.localizedStandardCompare(entry2.name) == .orderedAscending
            }
        }
        
        // Update UI on main thread
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - NSCollectionViewDataSource
extension PreviewViewController: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return isZipFile ? zipEntries.count : folderContents.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if isZipFile {
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ZipItemCell"), for: indexPath)
            
            guard let cell = item as? ZipItemCell else { return item }
            
            let zipEntry = zipEntries[indexPath.item]
            cell.configure(with: zipEntry)
            
            return cell
        } else {
            let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("ItemCell"), for: indexPath)
            
            guard let cell = item as? ItemCell else { return item }
            
            let fileURL = folderContents[indexPath.item]
            cell.configure(with: fileURL)
            
            return cell
        }
    }
}

// MARK: - NSCollectionViewDelegate
extension PreviewViewController: NSCollectionViewDelegate {
    // Handle item selection if needed
}

// MARK: - ZipEntry Model
struct ZipEntry {
    let name: String
    let path: String
    let isDirectory: Bool
    let size: UInt64
    let modificationDate: Date?
    let icon: NSImage
}

// MARK: - ZipItemCell for displaying ZIP entries
class ZipItemCell: NSCollectionViewItem {
    
    private let iconView = NSImageView()
    private let nameLabel = NSTextField()
    
    override init(nibName: NSNib.Name?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        // Configure view
        view = NSView(frame: NSRect(x: 0, y: 0, width: 120, height: 120))
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        
        // Configure icon view
        iconView.frame = NSRect(x: 30, y: 40, width: 60, height: 60)
        iconView.imageScaling = .scaleProportionallyUpOrDown
        
        // Configure name label
        nameLabel.frame = NSRect(x: 5, y: 5, width: 110, height: 30)
        nameLabel.isEditable = false
        nameLabel.isSelectable = false
        nameLabel.alignment = .center
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.maximumNumberOfLines = 2
        nameLabel.cell?.truncatesLastVisibleLine = true
        nameLabel.cell?.wraps = true
        nameLabel.drawsBackground = false
        nameLabel.isBezeled = false
        
        // Add subviews
        view.addSubview(iconView)
        view.addSubview(nameLabel)
    }
    
    func configure(with zipEntry: ZipEntry) {
        // Set icon
        iconView.image = zipEntry.icon
        
        // Set name
        nameLabel.stringValue = zipEntry.name
        
        // Set tooltip
        let sizeString = formatFileSize(zipEntry.size)
        let dateString = zipEntry.modificationDate != nil ?
            formatDate(zipEntry.modificationDate!) : "Unknown date"
        
        view.toolTip = "\(zipEntry.name)\nSize: \(sizeString)\nModified: \(dateString)"
    }
    
    private func formatFileSize(_ size: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(size))
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
