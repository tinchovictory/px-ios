//
//  PayerCostViewController.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 3/22/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

import UIKit

public class PayerCostViewController: MercadoPagoUIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var bundle : NSBundle? = MercadoPago.getBundle()
    var installments : [Installment]?
    var payerCosts : [PayerCost]?
    var paymentMethod : PaymentMethod?
    
    var cardFront : CardFrontView?
    
    @IBOutlet weak var cardView: UIView!
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    public init(paymentMethod : PaymentMethod?,issuer : Issuer?,cardToken : CardToken?,amount : Double?,minInstallments : Int?, callback : ((installment: PayerCost) -> Void)) {
        super.init(nibName: "PayerCostViewController", bundle: self.bundle)
     self.edgesForExtendedLayout = UIRectEdge.None
        //self.edgesForExtendedLayout = .All
         self.paymentMethod = paymentMethod
        MPServicesBuilder.getInstallments((cardToken?.getBin())!  , amount: amount!, issuer: issuer, paymentTypeId: PaymentTypeId.CREDIT_CARD, success: { (installments) -> Void in
            self.installments = installments
            self.payerCosts = installments![0].payerCosts
            //TODO ISSUER
           
            self.tableView.reloadData()
            }) { (error) -> Void in
                print("error!")
        }

    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        cardFront?.frame = cardView.bounds
  
    }
    
    
    public func updateCardSkin() {
        
        if(self.paymentMethod != nil){
            
            self.cardFront?.cardLogo.image =  MercadoPago.getImageFor(self.paymentMethod!)
            self.cardView.backgroundColor = MercadoPago.getColorFor(self.paymentMethod!)
            self.cardFront?.cardLogo.alpha = 1
        }
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        let installmentNib = UINib(nibName: "PayerCostTableViewCell", bundle: self.bundle)
        self.tableView.registerNib(installmentNib, forCellReuseIdentifier: "PayerCostTableViewCell")
        // Do any additional setup after loading the view.
        updateCardSkin()
        
    }

    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cardFront = CardFrontView()
        cardView.addSubview(cardFront!)
        
        

        
    }
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       
        return 50
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.payerCosts == nil){
            return 0
        }else{
            return self.payerCosts!.count
        }
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        


            let installmentCell = tableView.dequeueReusableCellWithIdentifier("PayerCostTableViewCell", forIndexPath: indexPath) as! PayerCostTableViewCell
        
        
        let payerCost : PayerCost = payerCosts![indexPath.row]
        let mpTurquesaColor = UIColor(netHex: 0x3F9FDA)
         let mpLightGrayColor = UIColor(netHex: 0x999999)
        
        let descriptionAttributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name: "ProximaNova-Light", size: 22)!,NSForegroundColorAttributeName:mpTurquesaColor]
        
        let totalAttributes: [String:AnyObject] = [NSFontAttributeName : UIFont(name: "ProximaNova-Light", size: 16)!,NSForegroundColorAttributeName:mpLightGrayColor]
        
        
        let stringToWrite = NSMutableAttributedString()
        
        stringToWrite.appendAttributedString(NSMutableAttributedString(string: "\(payerCost.installments.description) de ", attributes: descriptionAttributes))
        
         stringToWrite.appendAttributedString(Utils.getAttributedAmount(String(payerCost.installmentAmount), thousandSeparator: ",", decimalSeparator: ".", currencySymbol: "$" , color:mpTurquesaColor))
        
        stringToWrite.appendAttributedString(NSMutableAttributedString(string:" (", attributes: totalAttributes))
        stringToWrite.appendAttributedString(Utils.getAttributedAmount(String(payerCost.totalAmount), thousandSeparator: ",", decimalSeparator: ".", currencySymbol: "$" , color:mpLightGrayColor))
        stringToWrite.appendAttributedString(NSMutableAttributedString(string:")", attributes: totalAttributes))
        installmentCell.payerCostDetail.attributedText =  stringToWrite
            
            //= payerCosts![indexPath.row].recommendedMessage
            return installmentCell
        }
          }
    
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
    }





