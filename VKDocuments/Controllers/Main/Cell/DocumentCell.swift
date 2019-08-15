//
//  DocumentCell.swift
//  VKDocuments
//
//  Created by Егор Егоров on 14/08/2019.
//  Copyright © 2019 Егор Егоров. All rights reserved.
//

import UIKit

final class DocumentCell: UITableViewCell {

    static let identifier = "DocumentCell"
    static let height: CGFloat = UITableView.automaticDimension
    
    @IBOutlet private weak var documentTypeImageView: UIImageView!
    @IBOutlet private weak var documentNameLabel: UILabel!
    @IBOutlet private weak var documentDescriptionLabel: UILabel!
    
    override func prepareForReuse() {
        documentTypeImageView.image = nil
        documentNameLabel.text = ""
        documentDescriptionLabel.text = ""
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
        documentNameLabel.text = document.title
        documentDescriptionLabel.text = document.descriptionString
        documentTypeImageView.image = self.getFileIcon(byType: document.type)
    }
}
