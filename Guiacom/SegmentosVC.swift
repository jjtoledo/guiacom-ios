//
//  SegmentosVC.swift
//  Guiacom
//
//  Created by José Cassimiro on 11/06/16.
//  Copyright © 2016 Guiacom Manhuaçu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner

class SegmentosVC: UIViewController, UITableViewDataSource, UITableViewDelegate,
                    UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var listaSegs: UITableView!
    let getSegmentosURL = "http://guiacomdigital.com.br/webservice/listaSegmentosEmCidade.php"
    let citiesURL = "http://guiacomdigital.com.br/webservice/listaCidadesPossuemEmpresas.php"
    var segmentos = [Segmento]()
    
    var receivedCitySigla: String = ""
    var receivedCity: String = ""
    var receivedId: String = ""
    var segId: String = ""
    var segName: String = ""
    var cidades = [String]()
    var cidadesId = [String]()
    
    var alertView: UIAlertController!
    
    @IBOutlet weak var lbCityName: UILabel!
    
    @IBAction func btEmpresas(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func btBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btTrocaCidade(sender: AnyObject) {
        createAlertView()
    }
    
    @IBAction func btCadastro(sender: AnyObject) {
        performSegueWithIdentifier("menuCadastro", sender: self)
    }
    
    @IBAction func btPesquisa(sender: AnyObject) {
        if receivedCitySigla == ""{
            let alert = UIAlertController(title: "Atenção",
                                          message: "Selecione uma cidade primeiro!",
                                          preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: { (action: UIAlertAction!) in
                self.navigationController?.popToRootViewControllerAnimated(true)
            }))
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("menuPesquisa", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lbCityName.text = receivedCitySigla
        
        listaSegs.dataSource = self
        listaSegs.delegate = self
        
        getSegmentos()
        getCidades()
    }

    func getSegmentos() {
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, getSegmentosURL, parameters: ["android": "android", "id": receivedId])
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    if json.count == 0 {
                        SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                    }
                    
                    for i in 0...json.count {
                        let segmento = Segmento()
                        segmento.id = json[i]["id"].stringValue
                        segmento.nome = json[i]["nome"].stringValue
                        self.segmentos.append(segmento)
                    }
                    
                    SwiftSpinner.hide()
                }
                self.listaSegs.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: SegmentoCell = tableView.dequeueReusableCellWithIdentifier("Segmento") as! SegmentoCell
        
        cell.segmento.text = segmentos[indexPath.row].nome
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        segId = segmentos[indexPath.row].id
        segName = segmentos[indexPath.row].nome
        self.performSegueWithIdentifier("menuEmpresasSegs", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "menuEmpresasSegs" {
            let empresasSegsVC: EmpresasVC = segue.destinationViewController as! EmpresasVC
            empresasSegsVC.receivedCitySigla = self.receivedCitySigla
            empresasSegsVC.receivedCity = self.receivedCity
            empresasSegsVC.receivedSegId = self.segId
            empresasSegsVC.receivedCityId = self.receivedId
            empresasSegsVC.receivedSegName = self.segName
        } else if segue.identifier == "menuMain" {
            let mainVC: ViewController = segue.destinationViewController as! ViewController
            mainVC.cidadeId = receivedId
            mainVC.cidade = receivedCity
            alertView.dismissViewControllerAnimated(true, completion: nil)
        } else if segue.identifier == "menuPesquisa" {
            let pesquisaVC: PesquisaVC = segue.destinationViewController as! PesquisaVC
            pesquisaVC.receivedCitySigla = receivedCitySigla
            pesquisaVC.receivedCity = receivedCity
            pesquisaVC.receivedId = receivedId
        } else if segue.identifier == "menuCadastro" {
            let cadastroVC: CadastroViewController = segue.destinationViewController as! CadastroViewController
            cadastroVC.receivedCitySigla = receivedCitySigla
            cadastroVC.receivedCity = receivedCity
            cadastroVC.receivedId = receivedId
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cidades.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        receivedCity = cidades[row]
        receivedId = cidadesId[row]
        performSegueWithIdentifier("menuMain", sender: self)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cidades[row]
    }
    
    func getCidades() {
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, citiesURL, parameters: ["android": "android"])
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    if json.count == 0 {
                        SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                    }
                    
                    for i in 0...json.count {
                        self.cidades.append(json[i]["nome"].stringValue)
                        self.cidadesId.append(json[i]["id"].stringValue)
                    }
                    
                    SwiftSpinner.hide()
                }
        }
    }
    
    func createAlertView() {
        alertView = UIAlertController(title: "", message: "\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.Alert)
        
        let pickerView = UIPickerView(frame: CGRectMake(0,0,260,200))
        pickerView.dataSource = self
        pickerView.delegate = self
        
        alertView.view.addSubview(pickerView)
        presentViewController(alertView, animated: true, completion: nil)
    }
}
