import Cocoa
import QuickLookUI

class ItemCell: NSCollectionViewItem {
    
    // Use different names to avoid overriding existing properties
    private let itemImageView = NSImageView()
    private let fileNameLabel = NSTextField()
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = NSView()
        view.wantsLayer = true
        
        // Setup image view
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        itemImageView.imageScaling = .scaleProportionallyUpOrDown
        view.addSubview(itemImageView)
        
        // Setup label
        fileNameLabel.translatesAutoresizingMaskIntoConstraints = false
        fileNameLabel.isEditable = false
        fileNameLabel.isSelectable = false
        fileNameLabel.drawsBackground = false
        fileNameLabel.isBordered = false
        fileNameLabel.alignment = .center
        fileNameLabel.maximumNumberOfLines = 2
        fileNameLabel.lineBreakMode = .byTruncatingMiddle
        view.addSubview(fileNameLabel)
        
        NSLayoutConstraint.activate([
            itemImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
            itemImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            itemImageView.widthAnchor.constraint(equalToConstant: 64),
            itemImageView.heightAnchor.constraint(equalToConstant: 64),
            
            fileNameLabel.topAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: 5),
            fileNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2),
            fileNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -2),
            fileNameLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -5)
        ])
    }
    
    func configure(with fileURL: URL) {
        // Set file name
        fileNameLabel.stringValue = fileURL.lastPathComponent
        
        // Get file icon
        let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
        itemImageView.image = icon
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.image = nil
        fileNameLabel.stringValue = ""
    }
}
