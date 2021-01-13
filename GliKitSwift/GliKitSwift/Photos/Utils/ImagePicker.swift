//
//  ImagePicker.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/2.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import AVFoundation.AVCaptureDevice

///图片选择
public class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    ///图片选项
    public private(set) var options: PhotosOptions = PhotosOptions()
    
    ///图片回调
    private var completion: PhotosCompletion?
    
    ///关联的
    private weak var viewController: UIViewController?
    
    ///
    private var parent: UIViewController {
        var vc = viewController
        if vc == nil {
            vc = UIApplication.shared.delegate?.window??.rootViewController?.gkTopestPresentedViewController
        }
        
        return vc!
    }
    
    ///是否已调用
    private var hasPicker: Bool = false
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    ///选择图片
    public func pickImage(completion: @escaping PhotosCompletion) {
        self.completion = completion
        
        if(!hasPicker) {
            hasPicker = true
            let alert = AlertUtils.showActionSheet(title: "选择图片", buttonTitles: ["拍照", "相册"], cancelButtonTitle: "取消") { (index, _) in
                switch index {
                case 0 :
                    self.takePhotos()
                    
                case 1 :
                    self.album()
                    
                default :
                    break
                }
            }
            alert.dialogDismissCompletion = {
                self.hasPicker = false
            }
        }
    }
    
    // MARK: - 拍照
    
    ///相机是否可以使用 不能使用时会弹出对应错误
    static func canUseCamera(alert: Bool = true) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            if alert {
                AlertUtils.showAlert(title: "提示", message: "相机不可用", buttonTitles: ["确定"])
            }
            return false
        }
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .denied || status == .restricted  {
            if alert {
                let msg = "无法使用您的相机，请在本机的“设置-隐私-相机”中设置,允许\(AppUtils.appName)使用您的相机"
                AlertUtils.showAlert(title: "提示", message: msg, buttonTitles: ["取消", "去设置"]) { (index, _) in
                    if index == 1 {
                        AppUtils.openSettings()
                    }
                }
            }
            return false
        }
        
        return true
    }
    
    ///拍照
    private func takePhotos() {
        if ImagePicker.canUseCamera() {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.modalPresentationStyle = .fullScreen
            parent.present(picker, animated: true, completion: nil)
        }
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: false, completion: nil)
        
        if let originalImage = info[.originalImage] as? UIImage {
            parent.gkShowLoadingToast()
            DispatchQueue.global(qos: .default).async {
                let image = UIImage.gkFixOrientation(with: originalImage)
                if self.options.cropSettings != nil {
                    DispatchQueue.main.async {
                        self.parent.gkDismissLoadingToast()
                        self.options.cropSettings?.image = image
                        let imageCrop = ImageCropViewController(options: self.options)
                        self.parent.navigationController?.pushViewController(imageCrop, animated: true)
                    }
                } else {
                    let result = PhotosPickResult(image: image, options: self.options)
                    DispatchQueue.main.async {
                        self.parent.gkDismissLoadingToast()
                        self.completion?([result])
                    }
                }
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - 相册
    
    ///打开相册
    private func album() {
        let vc = PhotosViewController(options: options)
        options.completion = completion
        self.parent.present(vc.gkCreateWithNavigationController, animated: true, completion: nil)
    }
}
