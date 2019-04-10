//
//  QR_Scanning_Camera.swift
//  VeriDocG
//
//  Created by Bhavdip Patel on 08/12/18.
//  Copyright © 2018 SevenBits. All rights reserved.
//

import UIKit
import CoreGraphics
import AVFoundation

//class QR_Scanning_Camera: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}

///
///  This protocol defines methods which get called when some events occures.
///
public protocol QR_Scanning_CameraDelegate: class {
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String)
    func qrScannerDidFail(_ controller: UIViewController,  error: String)
    func qrScannerDidCancel(_ controller: UIViewController)
}

///QRCodeScannerController is ViewController which calls up method which presents view with AVCaptureSession and previewLayer
///to scan QR and other codes.

 class QR_Scanning_Camera: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var squareView: SquareView?
    public weak var delegate: QR_Scanning_CameraDelegate?
    var flashButton: UIButton = UIButton()
    var btn_TryAgain: UIButton = UIButton()
    var btn_GotoBack: UIButton = UIButton()
   // let vw_CameraBk: UIView!
    
    
    @IBOutlet weak var CameraView: UIView!
    //Extra images for adding extra features
    public var cameraImage: UIImage?
    public var cancelImage: UIImage?
    public var flashOnImage: UIImage?
    public var flashOffImage: UIImage?
    
    //Default Properties
    let bottomSpace: CGFloat = 00.0
    let spaceFactor: CGFloat = 16.0
    var devicePosition: AVCaptureDevice.Position = .back
    var delCnt: Int = 0
    var imgbk:  UIImageView =  UIImageView()
    var img_PlsLogin:  UIImageView =  UIImageView()
    var img_Opps:  UIImageView =  UIImageView()
    var lbl_Title:  UILabel!
    ///This is for adding delay so user will get sufficient time for align QR within frame
    let delayCount: Int = 15
    
    var window: UIWindow?
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    ///Convinience init for adding extra images (camera, torch, cancel)
    convenience public init(cameraImage: UIImage?, cancelImage: UIImage?, flashOnImage: UIImage?, flashOffImage: UIImage?) {
        self.init()
        self.cameraImage = cameraImage
        self.cancelImage = cancelImage
        self.flashOnImage = flashOnImage
        self.flashOffImage = flashOffImage
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func viewDidLoad() {
    
    }
    //MARK: Life cycle methods
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //  .restorationIdentifier == "smartlogin"
        
        
        //Currently only "Portraint" mode is supported
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        delCnt = 0
        prepareQRScannerView(self.view)
        startScanningQRCode()
        
        
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        let url = URL(string: "https://my.veridocglobal.com/login")
        UIApplication.shared.openURL(url!)
        
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Lazy initialization of properties
    
    ///Initialise CaptureDevice
    lazy var defaultDevice: AVCaptureDevice? = {
        if let device = AVCaptureDevice.default(for: .video) {
            return device
        }
        return nil
    }()
    
    ///Initialise front CaptureDevice
    lazy var frontDevice: AVCaptureDevice? = {
        if #available(iOS 10, *) {
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                return device
            }
        } else {
            for device in AVCaptureDevice.devices(for: .video) {
                if device.position == .front {
                    return device
                }
            }
        }
        return nil
    }()
    
    ///Initialise AVCaptureInput with defaultDevice
    lazy var defaultCaptureInput: AVCaptureInput? = {
        if let captureDevice = defaultDevice {
            do {
                return try AVCaptureDeviceInput(device: captureDevice)
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }()
    
    ///Initialise AVCaptureInput with frontDevice
    lazy var frontCaptureInput: AVCaptureInput?  = {
        if let captureDevice = frontDevice {
            do {
                return try AVCaptureDeviceInput(device: captureDevice)
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }()
    
    lazy var dataOutput = AVCaptureMetadataOutput()
    
    ///Initialise capture session
    lazy var captureSession = AVCaptureSession()
    
    ///Initialise videoPreviewLayer with capture session
    lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.cornerRadius = 10.0
        return layer
    }()
    
    /// This calls up methods which makes code ready for scan codes.
    /// - parameter view: UIView in which you want to add scanner.
    
    func prepareQRScannerView(_ view: UIView) {
        setupCaptureSession(devicePosition) //Default device capture position is rear
        addViedoPreviewLayer(view)
        createCornerFrame()
        addButtons(view)
    }
    
    ///Creates corner rectagle frame with green coloe(default color)
    func createCornerFrame() {
        
        let width: CGFloat = 200.0
        let height: CGFloat = 200.0
        var rectY: CGFloat = 0.0
        
        if restorationIdentifier == "smartlogin" {
            rectY = 65.0
        }
        
        
        let rect = CGRect.init(origin: CGPoint.init(x: view.frame.midX - width/2, y: rectY + view.frame.midY - (width+bottomSpace)/2), size: CGSize.init(width: width, height: height))
        self.squareView = SquareView(frame: rect)
        
        print(rect)
        
      
        
        
        if let squareView = squareView {
            view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
            squareView.autoresizingMask = UIViewAutoresizing(rawValue: UInt(0.0))
            view.addSubview(squareView)
            
            addMaskLayerToVideoPreviewLayerAndAddText(rect: rect)
        }
    }
    
    func addMaskLayerToVideoPreviewLayerAndAddText(rect: CGRect) {
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        // maskLayer.fillColor = UIColor(white: 0.0, alpha: 0.5).cgColor
        maskLayer.fillColor = UIColor.clear.cgColor
        let path = UIBezierPath(rect: rect)
        path.append(UIBezierPath(rect: view.bounds))
        maskLayer.path = path.cgPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        view.layer.insertSublayer(maskLayer, above: videoPreviewLayer)
        
        let noteText = CATextLayer()
        noteText.fontSize = 18.0
        noteText.string = ""
        noteText.alignmentMode = kCAAlignmentCenter
        noteText.contentsScale = UIScreen.main.scale
        noteText.frame = CGRect(x: spaceFactor, y: rect.origin.y + rect.size.height + 30, width: view.frame.size.width - (2.0 * spaceFactor), height: 22)
        noteText.foregroundColor = UIColor.white.cgColor
        view.layer.insertSublayer(noteText, above: maskLayer)
        
        
        btn_TryAgain = UIButton(frame: CGRect(x: maskLayer.frame.origin.x+25, y: maskLayer.frame.origin.y + 35, width: 150, height: 50))
        // btn_TryAgain.backgroundColor = .black
        btn_TryAgain.setBackgroundImage(UIImage(named: "icn_camera_tryagain"), for: .normal)
        btn_TryAgain.addTarget(self, action:#selector(self.btn_TryAgain1), for: .touchUpInside)
        self.squareView?.addSubview(btn_TryAgain)
        
        
        
        btn_GotoBack = UIButton(frame: CGRect(x: maskLayer.frame.origin.x+25, y: maskLayer.frame.origin.y + 120 , width: 150, height: 50))
        // btn_TryAgain.backgroundColor = .black
        btn_GotoBack.setBackgroundImage(UIImage(named: "icn_camera_goback"), for: .normal)
        btn_GotoBack.addTarget(self, action:#selector(self.btn_GotoBack1), for: .touchUpInside)
        self.squareView?.addSubview(btn_GotoBack)
        
        btn_GotoBack.isHidden = true
        btn_TryAgain.isHidden = true
        
    }
    
    
    @objc func btn_TryAgain1() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func btn_GotoBack1() {
       // kConstantObj.SetIntialMainViewController("PageViewController")
        self.dismiss(animated: false, completion: nil)
        let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_ScanNowLoading_ViewController")
        self.window?.rootViewController = mainVcIntial
        
        
    }
    func DeviceDetect() -> String {
        
        
        var str_DeviceType: String!
        
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone1")
                str_DeviceType = "iPhone1"
            case 1334:
                print("iPhone 6/6S/7/8")
                str_DeviceType = "iPhone2"
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                str_DeviceType = "iPhone3"
            case 2436:
                print("iPhone X, Xs")
                str_DeviceType = "iPhone4"
            case 2688:
                print("iPhone Xs Max")
                str_DeviceType = "iPhone5"
            case 1792:
                print("iPhone Xr")
                str_DeviceType = "iPhone6"
            default:
                print("unknown")
                str_DeviceType = "unknown"
            }
        }
        else {
            str_DeviceType = "unknown"
        }
        
        return str_DeviceType
    }
    
    /// Adds buttons to view which can we used as extra fearures
    private func addButtons(_ view: UIView) {
        
        if restorationIdentifier == "smartlogin" {
            let myNewView: UIView!
            
            if DeviceDetect() == "iPhone4" {
                myNewView=UIView(frame: CGRect(x: 0, y: 39, width: view.frame.size.width, height: 130))
            }else{
                  myNewView=UIView(frame: CGRect(x: 0, y: 19, width: view.frame.size.width, height: 130))
            }
            view.addSubview(myNewView)
            
            imgbk.frame = CGRect(x: 0, y: 0, width: myNewView.frame.width, height: myNewView.frame.height)
            myNewView.addSubview(imgbk)
            
          
            lbl_Title = UILabel(frame: CGRect(x: 60, y: 10, width: myNewView.frame.width - 70 , height: myNewView.frame.height-10))
             lbl_Title.numberOfLines = 100
            lbl_Title.textAlignment = NSTextAlignment.center
            myNewView.addSubview(lbl_Title)
            
           

            
            
            success_QR_Scanning()
          // faild_QR_Scanning()
    
        }
        
        let height: CGFloat = 35.0
        let width: CGFloat = 35.0
        let btnWidthWhenCancelImageNil: CGFloat = 60.0
        
        //Cancel button
        let cancelButton = UIButton()
        
        if let cancelImg = cancelImage {
            cancelButton.frame = CGRect(x: 16, y: 65, width: width, height: height)
            cancelButton.setImage(cancelImg, for: .normal)
        } else {
            cancelButton.frame = CGRect(x: view.frame.width/2 - btnWidthWhenCancelImageNil/2, y: view.frame.height - height, width: btnWidthWhenCancelImageNil, height: height)
            cancelButton.setTitle("Cancel", for: .normal)
        }
        cancelButton.layer.cornerRadius = height/2
        // cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cancelButton.backgroundColor = UIColor.clear
        cancelButton.contentMode = .scaleAspectFit
        cancelButton.addTarget(self, action: #selector(dismissVC), for:.touchUpInside)
        self.view.addSubview(cancelButton)
        
        //Torch button
        flashButton = UIButton(frame: CGRect(x: 16, y: self.view.bounds.size.height - (bottomSpace + height + 10), width: width, height: height))
        flashButton.tintColor = UIColor.white
        flashButton.layer.cornerRadius = height/2
        flashButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        flashButton.contentMode = .scaleAspectFit
        flashButton.addTarget(self, action: #selector(toggleTorch), for: .touchUpInside)
        if let flashOffImg = flashOffImage {
            flashButton.setImage(flashOffImg, for: .normal)
            self.view.addSubview(flashButton)
        }
        
        //Camera button
        let cameraButton = UIButton(frame: CGRect(x: self.view.bounds.width - (width + 16), y: self.view.bounds.size.height - (bottomSpace + height + 10), width: width, height: height))
        cameraButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        cameraButton.layer.cornerRadius = height/2
        cameraButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        cameraButton.contentMode = .scaleAspectFit
        if let cameraImg = cameraImage {
            cameraButton.setImage(cameraImg, for: .normal)
            self.view.addSubview(cameraButton)
        }
        
        
        
        if restorationIdentifier == "smartlogin" {
            
            cameraButton.isHidden = true
            flashButton.isHidden = true
            
        }
        
    }
    
    //Toggle torch
    @objc func toggleTorch() {
        //If device postion is front then no need to torch
        if let currentInput = getCurrentInput() {
            if currentInput.device.position == .front {
                return
            }
        }
        
        guard  let defaultDevice = defaultDevice else {return}
        if defaultDevice.isTorchAvailable {
            do {
                try defaultDevice.lockForConfiguration()
                defaultDevice.torchMode = defaultDevice.torchMode == .on ? .off : .on
                if defaultDevice.torchMode == .on {
                    if let flashOnImage = flashOnImage {
                        self.flashButton.setImage(flashOnImage, for: .normal)
                    }
                } else {
                    if let flashOffImage = flashOffImage {
                        self.flashButton.setImage(flashOffImage, for: .normal)
                    }
                }
                
                defaultDevice.unlockForConfiguration()
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    //Switch camera
    @objc func switchCamera() {
        if let frontDeviceInput = frontCaptureInput {
            captureSession.beginConfiguration()
            if let currentInput = getCurrentInput() {
                captureSession.removeInput(currentInput)
                let newDeviceInput = (currentInput.device.position == .front) ? defaultCaptureInput : frontDeviceInput
                captureSession.addInput(newDeviceInput!)
            }
            captureSession.commitConfiguration()
        }
    }
    
    private func getCurrentInput() -> AVCaptureDeviceInput? {
        if let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput {
            return currentInput
        }
        return nil
    }
    
    @objc func dismissVC() {
        self.dismiss(animated: true, completion: nil)
        delegate?.qrScannerDidCancel(self)
    }
    
    //MARK: - Setup and start capturing session
    
    open func startScanningQRCode() {
        if captureSession.isRunning {
            return
        }
        captureSession.startRunning()
    }
    
    private func setupCaptureSession(_ devicePostion: AVCaptureDevice.Position) {
        if captureSession.isRunning {
            return
        }
        
        switch devicePosition {
        case .front:
            if let frontDeviceInput = frontCaptureInput {
                if !captureSession.canAddInput(frontDeviceInput) {
                    delegate?.qrScannerDidFail(self, error: "Failed to add Input")
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                captureSession.addInput(frontDeviceInput)
            }
            break;
        case .back, .unspecified :
            if let defaultDeviceInput = defaultCaptureInput {
                if !captureSession.canAddInput(defaultDeviceInput) {
                    delegate?.qrScannerDidFail(self, error: "Failed to add Input")
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                captureSession.addInput(defaultDeviceInput)
            }
            break
        }
        
        if !captureSession.canAddOutput(dataOutput) {
            delegate?.qrScannerDidFail(self, error: "Failed to add Output")
            self.dismiss(animated: true, completion: nil)
            return
        }
        
        captureSession.addOutput(dataOutput)
        dataOutput.metadataObjectTypes = dataOutput.availableMetadataObjectTypes
        dataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    }
    
    ///Inserts layer to view
    private func addViedoPreviewLayer(_ view: UIView) {
        videoPreviewLayer.frame = CGRect(x:view.bounds.origin.x, y: view.bounds.origin.y, width: view.bounds.size.width, height: view.bounds.size.height - bottomSpace)
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
    }
    
    /// This method get called when Scanning gets complete
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        for data in metadataObjects {
            let transformed = videoPreviewLayer.transformedMetadataObject(for: data) as? AVMetadataMachineReadableCodeObject
            if let unwraped = transformed {
                if view.bounds.contains(unwraped.bounds) {
                    delCnt = delCnt + 1
                    if delCnt > delayCount {
                        if let unwrapedStringValue = unwraped.stringValue {
                            
                            //delegate?.qrScanner(self, scanDidComplete: unwrapedStringValue)
                            completedScan(unwrapedStringValue)
                            
                        } else {
                            delegate?.qrScannerDidFail(self, error: "Empty string found")
                            //faild_QR_Scanning()
                            //img_PlsLogin.image = UIImage(named: "icn_camera_red_bk1")
                        }
                       
                        //self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func completedScan(_ strQr: String){
        print(strQr)
        
        //   let newArr = strQr.components(separatedBy: ["(", ")"]).filter { $0 != "" }
        
        
        var str_WebFCMToken =  ""
        var str_WebName = ""
        
        let newArr = strQr.components(separatedBy: ["\n"])
        
        if newArr.count >= 1 {
            str_WebFCMToken = newArr[0]
        }
        
        if newArr.count >= 2 {
            str_WebName = newArr[1]
        }
        
        if str_WebFCMToken.count > 0 {
            if str_WebName.count > 0 {
                //Login_PushNoti(str_WebFCMToken, str_WebName: str_WebName)
                captureSession.stopRunning()
                delegate?.qrScanner(self, scanDidComplete: strQr)
                
                self.dismiss(animated: true, completion: nil)
            }else {
                faild_QR_Scanning()
            }
        }else {
           faild_QR_Scanning()
        }
        
        captureSession.stopRunning()
    }
    
    
    func faild_QR_Scanning() {
        imgbk.image = UIImage(named: "icn_camera_red_bk1")
        
        let str_Html = "<html><center><font size='4' color= white ' face='Helvetica Neue'> <B>Oops!<B> Looks like you’re trying to scan a QR Code that isn’t a Smart Login QR Code.<br>Please visit <B>https://my.veridocglobal.com/login<B> to generate a Smart Login QR and try logging in again.</font></center> </font> </html>"
        
        
        let data = str_Html.data(using: String.Encoding.unicode)! // mind "!"
        let attrStr = try? NSAttributedString( // do catch
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        lbl_Title.attributedText = attrStr
        
        btn_GotoBack.isHidden = false
        btn_TryAgain.isHidden = false
        
        
    }
    
    func success_QR_Scanning() {
        
        btn_GotoBack.isHidden = true
        btn_TryAgain.isHidden = true
        
        imgbk.image = UIImage(named: "icn_camera_green_bk1")
        
        let str_Html = "<html><center><font size='4' color= white ' face='Helvetica Neue'> Please Visit <br> <B>https://my.veridocglobal.com/login</B> and scan the QR present on your computer screen. <br> <font size-'3'> <i>(Please ensure notifications are turned on in your Settings)</i></font></font></center> </font> </html>"
        
        
        let data = str_Html.data(using: String.Encoding.unicode)! // mind "!"
        let attrStr = try? NSAttributedString( // do catch
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil)
        
        lbl_Title.attributedText = attrStr
    }
}

///Currently Scanner suppoerts only portrait mode.
///This makes sure orientation is portrait
extension QR_Scanning_Camera {
    ///Make orientations to portrait
    override public var shouldAutorotate: Bool {
        return false
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
}

/// This class is for draw corners of Square to show frame for scan QR code.
///@IBInspectable parameters are the line color, sizeMultiplier, line width.

@IBDesignable
class SquareView: UIView {
    @IBInspectable
    var sizeMultiplier : CGFloat = 0.1 {
        didSet{
            self.draw(self.bounds)
        }
    }
    
    @IBInspectable
    var lineWidth : CGFloat = 2 {
        didSet{
            self.draw(self.bounds)
        }
    }
    
    @IBInspectable
    var lineColor : UIColor = UIColor.white {
        didSet{
            self.draw(self.bounds)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
    }
    
    func drawCorners() {
        let rectCornerContext = UIGraphicsGetCurrentContext()
        
        rectCornerContext?.setLineWidth(lineWidth)
        rectCornerContext?.setStrokeColor(lineColor.cgColor)
        
        //top left corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: 0, y: 0))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width*sizeMultiplier, y: 0))
        rectCornerContext?.strokePath()
        
        //top rigth corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: self.bounds.size.width - self.bounds.size.width*sizeMultiplier, y: 0))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: 0))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.strokePath()
        
        //bottom rigth corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height - self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
        rectCornerContext?.addLine(to: CGPoint(x: self.bounds.size.width - self.bounds.size.width*sizeMultiplier, y: self.bounds.size.height))
        rectCornerContext?.strokePath()
        
        //bottom left corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: self.bounds.size.width*sizeMultiplier, y: self.bounds.size.height))
        rectCornerContext?.addLine(to: CGPoint(x: 0, y: self.bounds.size.height))
        rectCornerContext?.addLine(to: CGPoint(x: 0, y: self.bounds.size.height - self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.strokePath()
        
        //second part of top left corner
        rectCornerContext?.beginPath()
        rectCornerContext?.move(to: CGPoint(x: 0, y: self.bounds.size.height*sizeMultiplier))
        rectCornerContext?.addLine(to: CGPoint(x: 0, y: 0))
        rectCornerContext?.strokePath()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.drawCorners()
    }
    
    
    
}
