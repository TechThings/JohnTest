//
//  ProfilePictureViewModel.swift
//  FAVE
//
//  Created by Thanh KFit on 8/18/16.
//  Copyright © 2016 kfit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RSKImageCropper

final class ProfilePictureViewModel: ViewModel {

    let avatarViewModel = Variable<AvatarViewModel?>(nil)
    let canEditing = Variable(true)

    // MARK:- Dependency
    let userProvider: UserProvider

    init(
        canEditing: Bool
        , userProvider: UserProvider = userProviderDefault) {
        self.userProvider = userProvider
        self.canEditing.value = canEditing
        super.init()

        self.userProvider.currentUser
            .asObservable()
            .subscribeNext { [weak self](user) in
                self?.avatarViewModel.value = AvatarViewModel(initial: user.name, profileImageURL: user.profileImageURL)
            }.addDisposableTo(disposeBag)
    }

}

extension ProfilePictureViewModel {

    func updateProfilePicture() {
        let alert: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)

        alert.addAction(UIAlertAction(title: NSLocalizedString("take_photo", comment: ""), style: .Default, handler: {(action: UIAlertAction) -> Void in
            self.presentImagePickerWithSourceType(.Camera)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("choose_photo", comment: ""), style: .Default, handler: {(action: UIAlertAction) -> Void in
            self.presentImagePickerWithSourceType(.PhotoLibrary)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .Cancel, handler: nil))

        self.lightHouseService.navigate.onNext { (viewController: UIViewController) in
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func updateAvatar(image: UIImage) {
        let scale = UIScreen.mainScreen().scale
        let resizeImage = image.resize(CGSizeMake(200/scale, 200/scale))
        userProvider.updateProfileRequest(false, dateOfBirth: nil, gender: nil, purchaseNotification: nil, marketingNotification: nil, advertisingId: nil, profileImage: resizeImage)
    }

    func presentImagePickerWithSourceType(sourceType: UIImagePickerControllerSourceType) {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = self
        self.lightHouseService.navigate.onNext { (viewController: UIViewController) in
            viewController.presentViewController(picker, animated: true, completion: nil)
        }
    }

    func presentCropImageController(image: UIImage) {
        let imageCropVC: RSKImageCropViewController = RSKImageCropViewController(image: image)
        imageCropVC.delegate = self

        self.lightHouseService
        .navigate
        .onNext { (viewController) in
            viewController.navigationController?.pushViewController(imageCropVC, animated: true)
        }
    }
}

extension ProfilePictureViewModel: RSKImageCropViewControllerDelegate {
    // Crop image has been canceled.
    func imageCropViewControllerDidCancelCrop(controller: RSKImageCropViewController) {
        lightHouseService.navigate.onNext { (viewController: UIViewController) in
            viewController.navigationController?.popViewControllerAnimated(true)
        }
    }

    // The original image has been cropped.
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        updateAvatar(croppedImage)
        controller.navigationController?.popViewControllerAnimated(true)
    }

    // The original image has been cropped. Additionally provides a rotation angle used to produce image.
    func imageCropViewController(controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        updateAvatar(croppedImage)
        controller.navigationController?.popViewControllerAnimated(true)
    }
}

extension ProfilePictureViewModel : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true) {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.presentCropImageController(image)
            }
        }
    }
}
