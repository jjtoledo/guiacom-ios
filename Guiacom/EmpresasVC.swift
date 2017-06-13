//
//  EmpresasVC.swift
//  Guiacom
//
//  Created by José Cassimiro on 12/06/16.
//  Copyright © 2016 Guiacom Manhuaçu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner

class EmpresasVC: UIViewController, UITableViewDataSource, UITableViewDelegate,
                   UIPickerViewDataSource, UIPickerViewDelegate {
    
    var receivedCityId: String = ""
    var receivedSegId: String = ""
    var receivedSegName: String = ""
    var receivedCitySigla: String = ""
    var receivedCity: String = ""
    var cidades = [String]()
    var cidadesId = [String]()
    
    var alertView: UIAlertController!
    
    let getSegmentosURL = "http://guiacomdigital.com.br/webservice/listaEmpresasPorSegmento.php"
    let citiesURL = "http://guiacomdigital.com.br/webservice/listaCidadesPossuemEmpresas.php"
    var empresas = [Empresa]()
    var empresa = Empresa()
    
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
    
    @IBOutlet weak var lbCityName: UILabel!
    @IBOutlet weak var lbSegName: UILabel!
    
    @IBOutlet weak var listEmpresas: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        lbCityName.text = receivedCitySigla
        lbSegName.text = receivedSegName
        
        listEmpresas.dataSource = self
        listEmpresas.delegate = self
        
        getEmpresas()
        getCidades()
    }
    
    func getEmpresas() {
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, getSegmentosURL, parameters: ["android": "android", "id": receivedCityId, "segmento":  Int(receivedSegId)!])
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    if json.count == 0 {
                        SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                    }

                    for i in 0...json.count {
                        let empresa = Empresa()
                        empresa.apresentacao = json[i]["apresentacao"].stringValue
                        empresa.bairro = json[i]["bairro"].stringValue
                        empresa.cidade_id = json[i]["cidade_id"].stringValue
                        empresa.complemento = json[i]["complemento"].stringValue
                        empresa.email = json[i]["email"].stringValue
                        empresa.endereco = json[i]["endereco"].stringValue
                        empresa.logo = json[i]["logo"].stringValue
                        empresa.nome = json[i]["nome"].stringValue
                        empresa.nomeResponsavel = json[i]["nomeResponsavel"].stringValue
                        empresa.numero = json[i]["numero"].stringValue
                        empresa.pendente = json[i]["pendente"].stringValue
                        empresa.segmento_id = json[i]["segmento_id"].stringValue
                        empresa.site = json[i]["site"].stringValue
                        empresa.telefone1 = json[i]["telefone1"].stringValue
                        empresa.telefone2 = json[i]["telefone2"].stringValue
                        empresa.tipoCadastro = json[i]["tipoCadastro"].stringValue
                        empresa.wantsPremium = json[i]["wantsPremium"].stringValue
                        self.empresas.append(empresa)
                    }
                    
                    SwiftSpinner.hide()
                }
                self.listEmpresas.reloadData()
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return empresas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: EmpresaSegCell = tableView.dequeueReusableCellWithIdentifier("EmpresaSeg") as! EmpresaSegCell
        
        cell.bairro.text = empresas[indexPath.row].bairro
        cell.nome.text = empresas[indexPath.row].nome
        cell.telefone.text = empresas[indexPath.row].telefone1
        if ((cell.telefone.text?.containsString("\0")) != nil) {
            cell.telefone.text = cell.telefone.text?.stringByReplacingOccurrencesOfString("\0", withString: "")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.empresa = empresas[indexPath.row]
        if Int(self.empresa.tipoCadastro) == 0 {
            self.performSegueWithIdentifier("menuDetalhes", sender: self)
        } else {
            self.performSegueWithIdentifier("menuDetalhesPremium", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "menuPesquisa" {
            let pesquisaVC: PesquisaVC = segue.destinationViewController as! PesquisaVC
            pesquisaVC.receivedCitySigla = receivedCitySigla
            pesquisaVC.receivedCity = receivedCity
            pesquisaVC.receivedId = receivedCityId
        } else if segue.identifier == "menuDetalhes" {
            let detalhesVC: DetalhesVC = segue.destinationViewController as! DetalhesVC
            detalhesVC.empresa = self.empresa
            detalhesVC.receivedCitySigla = receivedCitySigla
            detalhesVC.receivedCity = receivedCity
            detalhesVC.receivedId = receivedCityId
        } else if segue.identifier == "menuDetalhesPremium" {
            let detalhesPremiumVC: DetalhesPremiumVC = segue.destinationViewController as! DetalhesPremiumVC
            detalhesPremiumVC.empresa = self.empresa
            detalhesPremiumVC.receivedCitySigla = receivedCitySigla
            detalhesPremiumVC.receivedCity = receivedCity
            detalhesPremiumVC.receivedId = receivedCityId
        } else if segue.identifier == "menuMain" {
            let mainVC: ViewController = segue.destinationViewController as! ViewController
            mainVC.cidadeId = receivedCityId
            mainVC.cidade = receivedCity
            alertView.dismissViewControllerAnimated(true, completion: nil)
        } else if segue.identifier == "menuCadastro" {
            let cadastroVC: CadastroViewController = segue.destinationViewController as! CadastroViewController
            cadastroVC.receivedCitySigla = receivedCitySigla
            cadastroVC.receivedCity = receivedCity
            cadastroVC.receivedId = receivedCityId
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
        receivedCityId = cidadesId[row]
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
