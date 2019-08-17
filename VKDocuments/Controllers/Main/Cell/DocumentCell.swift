//
//  DocumentCell.swift
//  VKDocuments
//
//  Created by Егор Егоров on 14/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit

protocol DocumentCellDelegate: class {
    func renameOnCell(cell: DocumentCell)
    func deleteOnCell(cell: DocumentCell)
}

final class DocumentCell: UITableViewCell {

    static let identifier = "DocumentCell"
    static let height: CGFloat = UITableView.automaticDimension
    
    weak var delegate: DocumentCellDelegate?
    
    @IBOutlet private weak var documentTypeImageView: UIImageView!
    @IBOutlet private weak var documentNameLabel: UILabel!
    @IBOutlet private weak var documentDescriptionLabel: UILabel!
    
    var document: Document?
    
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func prepareForReuse() {
        self.scrollView.contentOffset = CGPoint.zero
        
        documentTypeImageView.image = nil
        documentNameLabel.text = ""
        documentDescriptionLabel.text = ""
        
        self.document = nil
    }

    private func getFileIcon(byType type: Int) -> UIImage {
        switch type {
        case 1: return UIImage(named: "text") ?? UIImage()
        case 2: return UIImage(named: "archive") ?? UIImage()
        case 3, 4: return  UIImage(named: "image") ?? UIImage()
        case 5: return UIImage(named: "audio") ?? UIImage()
        case 6: return UIImage(named: "video") ?? UIImage()
        case 7: return UIImage(named: "book") ?? UIImage()
        default: return UIImage(named: "unknown") ?? UIImage()
        }
    }
    
    func update(for document: Document) {
        self.document = document
        
        documentNameLabel.text = document.title
        documentDescriptionLabel.text = document.descriptionString
        documentTypeImageView.image = self.getFileIcon(byType: document.type)
    }
}

extension DocumentCell {
    
    @IBAction func renameAction(_ sender: UIButton) {
        self.delegate?.renameOnCell(cell: self)
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        self.delegate?.deleteOnCell(cell: self)
    }
    
}

