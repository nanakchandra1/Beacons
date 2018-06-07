//
//  ShowCodeDetailVC.swift
//  SixthDegree
//
//  Created by Anuj Garg on 29/12/15.
//  Copyright © 2015 Appinventiv. All rights reserved.
//

import UIKit
import Foundation


//MARK:-Delegate ShowCodeDetailDelegate
//:-
protocol ShowCodeDetailDelegate{
    
func getCountryCode(_ text:String!,countryName:String!,max_NSN_Length:Int!,min_NSN_Length:Int!)
    
}



class ShowCodeDetailVC: UIViewController,UISearchBarDelegate{
    
    
    //MARK:-IBOutlet
    //:-
    
    @IBOutlet weak var naviDoneButton: UIButton!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var countryCodeTableView: UITableView!
    @IBOutlet weak var countrySearchBar: UISearchBar!
    
    //Update
    @IBOutlet weak var country_CodeLabel: UILabel!
    @IBOutlet weak var country_NameLabel: UILabel!
    @IBOutlet weak var check_Button: UIButton!
    @IBOutlet weak var countryInfo_View: UIView!
    
    var sections = [Section]()
    var filteredSection = [Section]()
    var countryArray = [[String:AnyObject]]()
    var filteredData = [[String:AnyObject]]()
    var getIndex:IndexPath?   //new
    var Max_NSN:Int!
    var Min_NSN:Int!
    var codeStr:String!
    var countryNameStr:String!
    
    var isTrue:Bool! = false
    var selectedIndexPath:IndexPath? = nil
    var delegate:ShowCodeDetailDelegate!
    
    //Update
    
    var sectionTitles : [String] = []
    let collation = UILocalizedIndexedCollation.current() as UILocalizedIndexedCollation
    
    
    //MARK:-view lifecycle method
    //:
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initializeSections()
        countrySearchBar.becomeFirstResponder()
        self.countryCodeTableView.dataSource = self
        self.countryCodeTableView.delegate = self
        self.resignFirstResponder()
        self.countrySearchBar.layer.cornerRadius = 4.0
        self.countrySearchBar.clipsToBounds = true
        countrySearchBar.clipsToBounds = true
        self.countrySearchBar.delegate = self
        let serarchColor =  UIColor(red: 213.0/255.0, green: 214.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        self.countrySearchBar.layer.borderColor = UIColor.white.cgColor
        self.countrySearchBar.layer.borderWidth = 1
        // self.countrySearchBar.barTintColor = serarchColor
        
        if let code = self.codeStr{
            self.country_CodeLabel.text = code
            self.country_NameLabel.text = self.countryNameStr
            self.contentHiddenFalse()
        }
        else{
        
            //Update
            // self.customizeSearchBar()
            self.country_CodeLabel.layer.cornerRadius = 4.0
            self.country_CodeLabel.clipsToBounds = true
            self.countryInfo_View.isHidden = true
            self.country_CodeLabel.isHidden = true
            self.country_NameLabel.isHidden = true
            self.check_Button.isHidden = true
}
        
        for subView in self.countrySearchBar.subviews  {
            for subsubView in subView.subviews  {
                if let textField = subsubView as? UITextField {
                    var bounds: CGRect
                    bounds = textField.frame
                    bounds.size.height = 25
                    textField.bounds = bounds
                    textField.borderStyle = UITextBorderStyle.roundedRect
                    
                    textField.backgroundColor = UIColor.red
                    
                }
            }
        }
        
        
        for subView in countrySearchBar.subviews
        {
            for subView1 in subView.subviews
            {
                
                if subView1.isKind(of: UITextField.self)
                {
                    subView1.backgroundColor = serarchColor
        
                }
            }
            
        }
        self.fetchCountryCodeFromSqlite()
        
        
    }
    
    
    //MARK:-view lifecycle method
    // :-
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    //MARK:-touchesBegan
    //:-
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.countryCodeTableView.endEditing(true)
        self.view.endEditing(true)
    }
    
   
    
    //MARK:- IBAction
    // :-
    
    @IBAction func naviDoneButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        delegate?.getCountryCode(self.codeStr,countryName: self.countryNameStr,max_NSN_Length: self.Max_NSN,min_NSN_Length: self.Min_NSN)
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    
    //MARK:-fetchCountryCodeFromSqlite
    //:------------------------------
    func fetchCountryCodeFromSqlite()
    {
        let handler: LookyLooCountryHandler = LookyLooCountryHandler()
        self.countryArray  = handler.fetchCountry().sortedArray(using: NSArray(object: NSSortDescriptor(key: "CountryEnglishName", ascending: true)) as! [NSSortDescriptor]) as![[String:AnyObject]]
        self.filteredData = self.countryArray
        self.addCountriesToSections()
        self.countryCodeTableView.reloadData()
    }
    
    
    
    
    //MARK:-Country Model class
    //:====
    class Country:NSObject
    {
        let countryName: String
        var countryCode: String
        var max_NSN_NO:Int!
        var min_NSN_NO:Int!
        
        init(name: String, countryCode: String,max_NSN_NO:Int!,min_NSN_NO:Int!) {
            self.countryName = name
            self.countryCode = countryCode
            self.max_NSN_NO = max_NSN_NO
            self.min_NSN_NO = min_NSN_NO
        }
    }
//
//    
//    
//    //Mark:-Model Class
//    //:-
    class Section
    {
        
        var countries: [Country] = []
        var sectionIndex: Int!
        func addCountry(_ country: Country) {
            self.countries.append(country)
        }
    }

    
    
//    //MARK:-initializeSections
//    //:-
    func initializeSections()
    {
        
        for _  in 0..<self.collation.sectionIndexTitles.count {
            self.sections.append(Section())
        }
    }
    
    func addCountriesToSections()
    {
        // create users from the name list
        
        for section in self.sections
        {
            if section.countries.count > 0
            {
                section.countries.removeAll()
            }
        }
        
        self.filteredSection.removeAll()
        
        let _: [Country] = self.filteredData.map { data in
            
            let country = Country(name: data["CountryEnglishName"] as! String, countryCode: data["CountryCode"] as! String,max_NSN_NO: data["Max_NSN"] as! Int, min_NSN_NO: data["Min_NSN"] as! Int)
            
            let sectionIndex: Int = self.collation.section(for: country, collationStringSelector: #selector(getter: Country.countryName))
            
            self.sections[sectionIndex].addCountry(country)
            self.sections[sectionIndex].sectionIndex = sectionIndex
            
            return country
        }
        
        
        //Mark:-Sort  for each section
        //:-
        for section in self.sections{
            section.countries = self.collation.sortedArray(from: section.countries, collationStringSelector: #selector(getter: Country.countryName)) as! [Country]
            if section.countries.count > 0
            {
                self.filteredSection.append(section)
            }
        }
    }
    
    
    // MARK:- UISearchBarDelegate Method
    //:-
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {

        if searchText.characters.count > 0
        {
            self.selectedIndexPath = nil
            self.filteredData = self.countryArray.filter({(dict: [String: AnyObject]) -> Bool in
                let array: [String] = (dict["CountryEnglishName"]!.lowercased).characters.split {$0 == " "}.map { String($0) }
                var matchedString:Bool = false
                for str in array
                {
                    matchedString = str.hasPrefix(searchText.lowercased())
                    if matchedString
                    {
                        break;
                    }
                }
                return matchedString
            })
        }
            
            
        else
        {
            self.filteredData = self.countryArray
            self.selectedIndexPath = self.getIndex
        }
        self.addCountriesToSections()
        
        self.countryCodeTableView.reloadData()
    }
    
    
    
}


//MARK:-TableView datasource and delegate method
//:-

extension ShowCodeDetailVC: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.filteredSection.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredSection[section].countries.count

    }
    
    func tableView(_ tableView: UITableView,titleForHeaderInSection section: Int)
        -> String?
    {
        if !self.filteredSection[section].countries.isEmpty
        {
            return self.collation.sectionTitles[self.filteredSection[section].sectionIndex] as String
        }
        return ""
    }
    
    
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.collation.sectionIndexTitles
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CodeDetailCell", for: indexPath) as! CodeDetailCell
        let country_Info = self.filteredSection[indexPath.section].countries[indexPath.row]
        cell.countryNameLabel.text! = country_Info.countryName
        cell.codeTextLabel.text! = country_Info.countryCode
//        self.Max_NSN = country_Info.max_NSN_NO
//        self.Min_NSN = country_Info.min_NSN_NO
        
        if (self.selectedIndexPath == indexPath){
            cell.checkImageView.image = UIImage(named: "tick")
            self.view.endEditing(true)
            delegate?.getCountryCode(self.codeStr,countryName: self.countryNameStr,max_NSN_Length: self.Max_NSN,min_NSN_Length: self.Min_NSN)
            self.dismiss(animated: true, completion: nil)

        }
        else{
            cell.checkImageView.image = UIImage(named: "uncheck")
        }
        
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let country_Info = self.filteredSection[indexPath.section].countries[indexPath.row]
        self.codeStr = country_Info.countryCode
        self.countryNameStr = country_Info.countryName
        self.Max_NSN = country_Info.max_NSN_NO
        self.Min_NSN = country_Info.min_NSN_NO
        self.country_CodeLabel.text = country_Info.countryCode
        self.country_NameLabel.text = country_Info.countryName
        self.contentHiddenFalse()
        
        if self.selectedIndexPath == indexPath
        {
            self.selectedIndexPath = nil
            

            self.countryCodeTableView.reloadRows(
                at: [indexPath],
                with:UITableViewRowAnimation.none)
            self.contentHiddenTrue()
            tableView.deselectRow(at: indexPath, animated:false)
            return
        }
        
        if selectedIndexPath == nil {
            self.selectedIndexPath = indexPath
            self.getIndex = indexPath
            self.countryCodeTableView.reloadData()
            return
        }
        
        tableView.reloadRows(at: [indexPath],with:UITableViewRowAnimation.none)
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 25)
        view.backgroundColor = UIColor(red: 205.0/255.0, green: 205.0/255.0, blue: 205.0/255.0, alpha: 1.0)
        let lab : UILabel = UILabel()
         lab.font = UIFont(name: "Avenir-Light", size: 12.0)
    
        lab.textColor = UIColor(red: 105.0/255.0, green: 105.0/255.0, blue: 105.0/255.0, alpha: 1.0)
        lab.frame = CGRect(x: 72, y: 0, width: UIScreen.main.bounds.width, height: 25)
        lab.text = self.collation.sectionTitles[self.filteredSection[section].sectionIndex] as String
        view.addSubview(lab)
        return view
    }
    
    
    //MARK:-contentHiddenTrue
    //:======================
    func contentHiddenTrue(){
        self.countryInfo_View.isHidden = true
        self.country_CodeLabel.isHidden = true
        self.country_NameLabel.isHidden = true
        self.check_Button.isHidden = true
    }
    
    
    //MARK:-contentHiddenFalse
    //:=======================
    
    func contentHiddenFalse(){
        self.countryInfo_View.isHidden = false
        self.country_CodeLabel.isHidden = false
        self.country_NameLabel.isHidden = false
        self.check_Button.isHidden = false
    }
    
    //MARK:-cellDataIfo
    //:===============
    func cellDataIfo(){
        print_debug("countryName=====\( self.countryNameStr)")
        print_debug(" self.codeStr:-->\( self.codeStr)")
        print_debug("maxNSN =====\(self.Max_NSN)")
        print_debug("minNSN =====\(self.Min_NSN)")
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.countryCodeTableView.frame.height/10
    }
    
}

