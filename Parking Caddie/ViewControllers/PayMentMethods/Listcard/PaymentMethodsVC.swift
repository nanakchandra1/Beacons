//
//  PaymentMethodsVC.swift
//  Sample
//
//  Created by Appinventiv on 14/09/17.
//  Copyright © 2017 Appinventiv. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol PayNowDelegate {
    
    func PayNow()
}

enum PaymentMethodState {
    case SideMenu,Request
}

enum PaymentCardState {
    case Add, Pay
}

class PaymentMethodsVC: UIViewController {

    
    //MARK:- IBOutlets
    //MARK:- ========================================
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var navigationTitle: UILabel!
    @IBOutlet weak var paymentMethodTableView: UITableView!

    @IBOutlet weak var addCradBtn: UIButton!
    @IBOutlet weak var payNowBtnHeightConstant: NSLayoutConstraint!
    
    //MARK:- Properties
    //MARK:- ========================================

    var selectedIndexPath: IndexPath?
    var moreOptionIndexPath: IndexPath?
    var delegate:PayNowDelegate!
    var paymentMethodState = PaymentMethodState.SideMenu
    var savedCards = [SavedCardsModel]()
    var state = PaymentCardState.Add
    
    
    //MARK:- View life cycle methods
    //MARK:- ========================================

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupViews()
        
        
        
//        UIView.animate(withDuration: 1) {
//            
//            self.view.layoutIfNeeded()
//
//            let shapeLayer = CAShapeLayer()
//            shapeLayer.strokeColor = UIColor.blue.cgColor
//            shapeLayer.fillColor = UIColor.white.cgColor
//            shapeLayer.lineWidth = 3
//            shapeLayer.position = CGPoint(x: 10, y: 10)
//            shapeLayer.path = self.getPathForLetter(letter: "N").cgPath
//
//            self.navigationView.layer.addSublayer(shapeLayer)
//            
//        }
    }

    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: .setCardNoNotificationName, object: nil);

    }
    
    //MARK:- IBActions
    //MARK:- ========================================
    
//    func getPathForLetter(letter: Character) -> UIBezierPath {
//        
//        var path = UIBezierPath()
//        let font = CTFontCreateWithName("HelveticaNeue" as CFString, 64, nil)
//        var unichars = [UniChar]("\(letter)".utf16)
//        var glyphs = [CGGlyph](repeating: 0, count: unichars.count)
//        
//        let gotGlyphs = CTFontGetGlyphsForCharacters(font, &unichars, &glyphs, unichars.count)
//        if gotGlyphs {
//            let cgpath = CTFontCreatePathForGlyph(font, glyphs[0], nil)
//            path =  UIBezierPath(cgPath: cgpath!)//UIBezierPath(CGPath: cgpath!)
//        }
//        
//        return path
//    }
    
    @IBAction func backBtnTapped(_ sender: UIButton) {
        
        APPDELEGATEOBJECT.parentNavigationController.popViewController(animated: true)
    }

    @IBAction func addCardBtnTapp(_ sender: UIButton) {
        
        self.moreOptionIndexPath = nil
        self.paymentMethodTableView.reloadData()
        
        CommonFunctions.getclientToken(self)

    }
    
    @IBAction func payNowbtnTap(_ sender: UIButton) {
        
        guard !self.savedCards.isEmpty else {return}
        let cToken: JSONDictionary = ["cToken": self.savedCards[self.selectedIndexPath!.row].token]
        APPDELEGATEOBJECT.parentNavigationController.popViewController(animated: true)
        NotificationCenter.default.post(name: .PayNowNotificationName, object: nil, userInfo: cToken)

    }

}


//MARK:- Private methods
//MARK:- ======================================

extension PaymentMethodsVC{
    
    fileprivate func setupViews(){
        
        if self.state == .Add{
            
            self.payNowBtnHeightConstant.constant = 0
            
        }else{
            
            self.backBtn.isHidden = true
        }

        self.paymentMethodTableView.delegate = self
        
        self.paymentMethodTableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.addCard(_ :)), name: .setCardNoNotificationName, object: nil)

        self.getCardList()
        
    }

    func addCard(_ notification: Notification){
    
        let info = JSON(notification.userInfo!)
        
        let card = SavedCardsModel(with: info)
        
        self.savedCards.append(card)
        
        self.paymentMethodTableView.reloadData()
    }
    
    fileprivate func getCardList(){
    
        var params = JSONDictionary()
        
        params["bt_customer_id"] = CurrentUser.customer_id
        
        CommonClass.startLoader()
        
        WebserviceController.getCardAPI(params, succesBlock: { (success, json) in
            
            self.savedCards = []
            
            let result = json["result"]
            
            let paymentMethods = result["paymentMethods"].arrayValue
            
            self.savedCards = paymentMethods.map({ (savedCard) -> SavedCardsModel in
                
                SavedCardsModel.init(with: savedCard)
            })

            self.paymentMethodTableView.reloadData()
            
        }) { (error) in
            
        }
    }
    
    fileprivate func deleteCard(indexPath: IndexPath){
        
        var params = JSONDictionary()
        
        params["the_token"] = self.savedCards[indexPath.row].token
        
        CommonClass.startLoader()

        WebserviceController.deleteCardAPI(params, succesBlock: { (success, json) in
            
            self.savedCards.remove(at: indexPath.row)
            
            self.paymentMethodTableView.reloadData()

        }) { (error) in
            
        }
    }

    
    fileprivate func makeDefaultCard(indexPath: IndexPath){
        
        var params = JSONDictionary()
        
        params["the_token"] = self.savedCards[indexPath.row].token
        
        params["p_mode"] = "card"
        
        CommonClass.startLoader()

        WebserviceController.makeDefaultCardAPI(params, succesBlock: { (success, json) in
            
            self.savedCards[indexPath.row].default_type = true
            userDefaults.set(self.savedCards[indexPath.row].token, forKey: NSUserDefaultsKeys.C_TOKEN)
            self.savedCards[self.selectedIndexPath!.row].default_type = false

            self.paymentMethodTableView.reloadData()

        }) { (error) in
            
        }
    }
    
}



//MARK:- TableView delegate and datasorces
//MARK:- ======================================

extension PaymentMethodsVC: UITableViewDelegate,UITableViewDataSource{


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.savedCards.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 125
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentMethodCell", for: indexPath) as! PaymentMethodCell
        
        if self.state == .Add{
            
            cell.radioTickWidthConst.constant = 0
            
            cell.radioTick.isHidden = true
            
        }

            if self.savedCards[indexPath.row].default_type{
            
                cell.defaultCardTick.image = #imageLiteral(resourceName: "ic_payment_tick")
                
                cell.optionBtn.isHidden = true
                cell.radioTick.image = #imageLiteral(resourceName: "radio_tick")
                self.selectedIndexPath = indexPath
                cell.defaultCardLbl.text = "Default Card"
                
            }else{
                
                cell.defaultCardTick.image = #imageLiteral(resourceName: "ic_payment_tick_circle")
                cell.radioTick.image = #imageLiteral(resourceName: "radio")

                cell.optionBtn.isHidden = false
                
                cell.defaultCardLbl.text = "Make Default"

            }
        
            cell.optionBtn.addTarget(self, action: #selector(self.optionBtnTaped(_:)), for: .touchUpInside)
        
            cell.removeCardBtn.addTarget(self, action: #selector(self.removeBtnTaped(_:)), for: .touchUpInside)

            cell.populatewData(indexPath, optionSelectedIndexPath: self.moreOptionIndexPath , card: self.savedCards[indexPath.row])
            return cell

        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
            if self.selectedIndexPath != indexPath{
                
                self.makeDefaultCard(indexPath: indexPath)
                
                self.moreOptionIndexPath = nil
                
                self.paymentMethodTableView.reloadData()
                
            }

    }
    
    // target methods
    // =============================
    
    func optionBtnTaped(_ sender: UIButton){
    
        
        guard let indexPath = sender.tableViewIndexPath(self.paymentMethodTableView) else{ return}

        self.moreOptionIndexPath = indexPath
        self.paymentMethodTableView.reloadData()
    }
    
    
    func removeBtnTaped(_ sender: UIButton){
        
        guard let indexPath = sender.tableViewIndexPath(self.paymentMethodTableView) else{ return}
        self.deleteCard(indexPath: indexPath)
        self.moreOptionIndexPath = nil

    }

    func addNewCard(_ sender: UIButton){
        self.moreOptionIndexPath = nil
        self.paymentMethodTableView.reloadData()

        CommonFunctions.getclientToken(self)
    }

}


//MARK:- TableView cell Classess
//MARK:- ======================================


class PaymentMethodCell: UITableViewCell{

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var cardNoLbl: UILabel!
    @IBOutlet weak var defaultCardView: UIView!
    @IBOutlet weak var defaultCardLbl: UILabel!
    @IBOutlet weak var defaultCardTick: UIImageView!
    @IBOutlet weak var optionBtn: UIButton!
    @IBOutlet weak var cardTypeImg: UIImageView!
    @IBOutlet weak var defaultCardBtn: UIButton!
    @IBOutlet weak var removeCardBtn: UIButton!
    @IBOutlet weak var radioTick: UIImageView!
    @IBOutlet weak var radioTickWidthConst: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.bgView.layer.cornerRadius = 2
        self.removeCardBtn.layer.cornerRadius = 2
        self.removeCardBtn.dropShadow()
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    

    
    func populatewData(_ indexPath: IndexPath, optionSelectedIndexPath: IndexPath?,card: SavedCardsModel){
    
        if indexPath == optionSelectedIndexPath{
            
            self.removeCardBtn.isHidden = false
            
        }else{
            
            self.removeCardBtn.isHidden = true

        }
        
        self.cardNoLbl.text = card.maskedNumber
        
        if let imageUrl = URL(string: card.imageUrl) {
            
            self.cardTypeImg.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: ""))
        }
    }
}



class AddCardBtnCell: UITableViewCell{
    
    @IBOutlet weak var addnewCardBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.addnewCardBtn.layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1).cgColor
        self.addnewCardBtn.layer.borderWidth = 1.0
        

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


