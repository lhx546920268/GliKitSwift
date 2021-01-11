//
//  ScanViewController.swift
//  GliKitSwift
//
//  Created by 罗海雄 on 2020/11/5.
//  Copyright © 2020 luohaixiong. All rights reserved.
//

import UIKit
import AVFoundation

///二维码扫描
open class ScanViewController: BaseViewController {
    
    ///支持的扫码类型
    public var supportedTypes: [AVMetadataObject.ObjectType] = [.qr]
    
    ///扫描结果回调
    public var scanCallback: ((_ result: String?, _ type: AVMetadataObject.ObjectType) -> Void)?
    
    ///是否正在暂停，暂停的时候无法开始
    public var isPausing: Bool = false {
        didSet{
            if oldValue != isPausing {
                if isPausing {
                    stopScan()
                } else {
                    startScan()
                }
            }
        }
    }
    
    ///是否需要设置扫描区域，不设置时，即便二维码不在扫描框内也可以扫描成功
    public var shouldRectOfInterest: Bool = true
    
    ///二维码扫描背景
    private let scanBackgroundView: ScanBackgroundView = ScanBackgroundView()
    
    ///摄像头调用会话
    private var session: AVCaptureSession?
    
    ///摄像头输入
    private var input: AVCaptureDeviceInput?
    
    ///摄像头输出
    private var output: AVCaptureMetadataOutput?
    
    ///摄像头图像预览
    private var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    ///解码队列
    private lazy var decodeQueue: DispatchQueue = {
        DispatchQueue(label: "com.glikit.scanDecode")
    }()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        navigationItem.title = "扫码"
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.startScan()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.stopScan()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captureVideoPreviewLayer?.frame = scanBackgroundView.frame
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) || backFacingCamera == nil {
            //检测摄像头是否可用
            onCaptureDeviceUnavailable()
        } else {
            //检测摄像头授权状态
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .notDetermined :
                AVCaptureDevice.requestAccess(for: .video) { [weak self] (granted) in
                    //可能不在主线程
                    dispatchAsyncMainSafe {
                        if granted {
                            self?.setupSession()
                        } else {
                            self?.onAuthorizationDenied()
                        }
                    }
                }
                
            case .denied, .restricted :
                onAuthorizationDenied()
                
            case .authorized :
                setupSession()
                
            @unknown default:
                break
            }
        }
        
        scanBackgroundView.scanBoxRectDidChange = { [weak self] (rect) in
            self?.setRectOfInterest()
        }
        self.contentView = scanBackgroundView
    }
    
    ///没权限
    open func onAuthorizationDenied() {
        AlertUtils.showAlert(title: "提示",
                             message: "无法使用您的相机，请在本机的“设置-隐私-相机”中设置,允许\(AppUtils.appName)使用您的相机",
                             buttonTitles: ["取消", "去设置"]) { (index, _) in
            if index == 1 {
                AppUtils.openSettings()
            }
        }
    }
    
    ///摄像头不可用
    open func onCaptureDeviceUnavailable() {
        AlertUtils.showAlert(title: "提示", message: "摄像头不可用", buttonTitles: ["确定"])
    }
    
    ///有结果了 会暂停扫描
    public func onScanCode(_ code: String?, type: AVMetadataObject.ObjectType) {
        
    }
    
    ///开始扫描
    public func startScan() {
        if !isPausing, let session = self.session, !session.isRunning {
            scanBackgroundView.startAnimating()
            session.startRunning()
        }
    }
    
    ///停止扫描
    public func stopScan() {
        if let session = self.session, session.isRunning {
            scanBackgroundView.stopAnimating()
            session.stopRunning()
        }
    }
    
    // MARK: - 相册
    
    ///打开相册扫描
    public func openPhotos() {
        let vc = PhotosViewController()
        vc.photosOptions.intention = .singleSelection
        vc.photosOptions.needOriginalImage = true
        vc.photosOptions.compressedImageSize = .zero
        vc.photosOptions.completion = { [weak self] (results) in
            self?.detectBarCode(from: results[0].originalImage!)
        }
        present(vc.gkCreateWithNavigationController, animated: true)
    }
    
    ///相册图片识别失败
    public func onDetectFail() {
        gkShowErrorText("图片识别失败")
    }
    
    ///识别图片中的二维码
    private func detectBarCode(from image: UIImage) {
        if let cgImage = image.cgImage {
            let context = CIContext()
            let options: [String: String] = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            if let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options) {
                let features = detector.features(in: CIImage(cgImage: cgImage))
                
                if features.count > 0,
                   let feature = features.first as? CIQRCodeFeature,
                   let result = feature.messageString {
                    processResult(result, type: .qr)
                    return
                }
            }
        }
        onDetectFail()
    }
    
    // MARK: - 二维码扫描设置
    
    ///设置开灯状态
    public func setLampOpen(_ open: Bool) {
        if let device = backFacingCamera {
            if device.hasTorch {
                do {
                    try device.lockForConfiguration()
                    if open {
                        device.torchMode = .on
                    } else {
                        device.torchMode = .off
                    }
                    device.unlockForConfiguration()
                }catch{
                    
                }
            }
        }
    }
    
    //通过摄像头位置，获取可用的摄像头
    private func camera(at position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        let devices = discoverySession.devices
        for device in devices {
            if device.position ==  position {
                return device
            }
        }
        return nil
    }
    
    //获取后置摄像头
    private var _backFacingCamera: AVCaptureDevice?
    private var backFacingCamera: AVCaptureDevice? {
        if _backFacingCamera == nil {
            _backFacingCamera = camera(at: .back)
        }
        return _backFacingCamera
    }
    
    //二维码扫描摄像头设置
    private func setupSession() {
        //初始化摄像头信息采集
        if let camera = backFacingCamera {
            do {
                let input = try AVCaptureDeviceInput(device: camera)
                let output = AVCaptureMetadataOutput()
                output.setMetadataObjectsDelegate(self, queue: decodeQueue)
                
                let session = AVCaptureSession()
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
                }
                
                //设置可扫描的类型
                let types = supportedTypes
                var availableTypes: [AVMetadataObject.ObjectType] = []
                let enabledTypes = output.availableMetadataObjectTypes
                
                for type in types {
                    if enabledTypes.contains(type) {
                        availableTypes.append(type)
                    }
                }
                output.metadataObjectTypes = availableTypes
                setRectOfInterest()
                
                //要判断是否支持，否则会蹦
                if session.canSetSessionPreset(.hd1920x1080) {
                    session.sessionPreset = .hd1920x1080
                } else if session.canSetSessionPreset(.high) {
                    session.sessionPreset = .high
                }
                
                //图像图层
                let layer = AVCaptureVideoPreviewLayer(session: session)
                layer.frame = scanBackgroundView.frame
                layer.videoGravity = .resizeAspectFill
                view.layer.insertSublayer(layer, at: 0)
                
                if isDisplaying {
                    startScan()
                }
                
                self.input = input
                self.output = output
                self.captureVideoPreviewLayer = layer
                self.session = session
            }catch{
                gkShowErrorText("相机打开失败")
            }
        }
    }
    
    ///设置扫描区域
    private func setRectOfInterest() {
        if let output = self.output, shouldRectOfInterest {
            let rect = scanBackgroundView.scanBoxRect
            let width = scanBackgroundView.gkWidth
            let height = scanBackgroundView.gkHeight
            
            //设置解析范围
            if rect.width > 0 && rect.height > 0 && width > 0 && height > 0 {
                output.rectOfInterest = CGRect(rect.minY / height, rect.minX / width, rect.height / height, rect.width / 2)
            } else {
                output.rectOfInterest = CGRect(0, 0, 1, 1)
            }
        }
    }
    
    ///处理描结果
    private func processResult(_ result: String?, type: AVMetadataObject.ObjectType) {
        if let callback = scanCallback {
            callback(result, type)
            gkBack()
        } else {
            onScanCode(result, type: type)
        }
    }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    ///判断类型
    func isAVMetadataObjectAvailable(_ object: AVMetadataObject) -> Bool {
        supportedTypes.contains(object.type)
    }
    
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for object in metadataObjects {
            if let codeObject = object as? AVMetadataMachineReadableCodeObject {
                if isAVMetadataObjectAvailable(codeObject) {
                    dispatchAsyncMainSafe {
                        if !self.isPausing {
                            self.isPausing = true
                            self.processResult(codeObject.stringValue, type: object.type)
                        }
                    }
                }
            }
        }
    }
}
