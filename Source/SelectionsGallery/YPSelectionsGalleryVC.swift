//
//  SelectionsGalleryVC.swift
//  YPImagePicker
//
//  Created by Nik Kov || nik-kov.com on 09.04.18.
//  Copyright © 2018 Yummypets. All rights reserved.
//

import UIKit

public class YPSelectionsGalleryVC: UIViewController {

    weak var rootNavigation: RootNavigation?
    public var items: [YPMediaItem] = []
    public var didFinishHandler: ((_ gallery: YPSelectionsGalleryVC, _ items: [YPMediaItem]) -> Void)?
    private var lastContentOffsetX: CGFloat = 0
    
    var v = YPSelectionsGalleryView()
    let config: YPImagePickerConfiguration
    public override func loadView() { view = v }

    public required init(items: [YPMediaItem],
                         config: YPImagePickerConfiguration,
                         didFinishHandler:
        @escaping ((_ gallery: YPSelectionsGalleryVC, _ items: [YPMediaItem]) -> Void)) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        self.items = items
        self.didFinishHandler = didFinishHandler
        self.rootNavigation = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Register collection view cell
        v.collectionView.register(YPSelectionsGalleryCell.self, forCellWithReuseIdentifier: "item")
        v.collectionView.dataSource = self
        v.collectionView.delegate = self
        
        // Setup navigation bar
        rootNavigation?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: config.wordings.next,
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(done))
        rootNavigation?.navigationItem.rightBarButtonItem?.tintColor = config.colors.tintColor
        
        YPHelper.changeBackButtonIcon(self, config: config)
        YPHelper.changeBackButtonTitle(self, config: config)
    }

    @objc
    private func done() {
        // Save new images to the photo album.
        if config.shouldSaveNewPicturesToAlbum {
            for m in items {
                if case let .photo(p) = m, let modifiedImage = p.modifiedImage {
                    YPPhotoSaver.trySaveImage(modifiedImage, inAlbumNamed: config.albumName)
                }
            }
        }
        didFinishHandler?(self, items)
    }
    
    @objc
    private func removeButtonDidClick(sender: UIButton) {
        guard let cell = sender.superview as? UICollectionViewCell, let indexPath = v.collectionView.indexPath(for: cell) else {
            return
        }
        items.remove(at: indexPath.row)
        v.collectionView.performBatchUpdates({
            v.collectionView.deleteItems(at: [indexPath])
        }, completion: { _ in })
    }
}

// MARK: - Collection View
extension YPSelectionsGalleryVC: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "item",
                                                            for: indexPath) as? YPSelectionsGalleryCell else {
            return UICollectionViewCell()
        }
        cell.config = config
        let item = items[indexPath.row]
        switch item {
        case .photo(let photo):
            cell.imageView.image = photo.image
            cell.setEditable(config.showsPhotoFilters)
        case .video(let video):
            cell.imageView.image = video.thumbnail
            cell.setEditable(config.showsVideoTrimmer)
        }
        
        if !config.gallery.hidesRemoveButton {
            cell.addRemoveButton(target: self, action: #selector(removeButtonDidClick(sender:)))
        }
        
        return cell
    }
}

extension YPSelectionsGalleryVC: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        var mediaFilterVC: IsMediaFilterVC?
        switch item {
        case .photo(let photo):
            if !config.filters.isEmpty, config.showsPhotoFilters {
                mediaFilterVC = YPPhotoFiltersVC(inputPhoto: photo, isFromSelectionVC: true, config: config)
            }
        case .video(let video):
            if config.showsVideoTrimmer {
                mediaFilterVC = YPVideoFiltersVC.initWith(video: video, isFromSelectionVC: true, config: config)
            }
        }
        
        mediaFilterVC?.didSave = { outputMedia in
            self.items[indexPath.row] = outputMedia
            collectionView.reloadData()
            self.dismiss(animated: true, completion: nil)
        }
        mediaFilterVC?.didCancel = {
            self.dismiss(animated: true, completion: nil)
        }
        if let mediaFilterVC = mediaFilterVC as? UIViewController {
            let navVC = UINavigationController(rootViewController: mediaFilterVC)
            navVC.navigationBar.isTranslucent = false
            present(navVC, animated: true, completion: nil)
        }
    }
    
    // Set "paging" behaviour when scrolling backwards.
    // This works by having `targetContentOffset(forProposedContentOffset: withScrollingVelocity` overriden
    // in the collection view Flow subclass & using UIScrollViewDecelerationRateFast
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let isScrollingBackwards = scrollView.contentOffset.x < lastContentOffsetX
        scrollView.decelerationRate = isScrollingBackwards
            ? UIScrollView.DecelerationRate.fast
            : UIScrollView.DecelerationRate.normal
        lastContentOffsetX = scrollView.contentOffset.x
    }
}
