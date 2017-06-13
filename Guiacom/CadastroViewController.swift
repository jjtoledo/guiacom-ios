//
//  CadastroViewController.swift
//  Guiacom
//
//  Created by José Cassimiro on 05/06/16.
//  Copyright © 2016 Guiacom Manhuaçu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner

class CadastroViewController: UIViewController, UIPickerViewDataSource,
                UIPickerViewDelegate, AKMaskFieldDelegate {

    var receivedCitySigla: String = ""
    var receivedCity: String = ""
    var receivedId: String = ""
    
    let getSegmentosURL = "http://guiacomdigital.com.br/webservice/listaSegmentos.php"
    let getEstadosURL = "http://guiacomdigital.com.br/webservice/listaEstados.php"
    let getCidadesURL = "http://guiacomdigital.com.br/webservice/listaCidadesEmEstado.php"
    let addURL = "http://guiacomdigital.com.br/webservice/cadastroEmpresa.php"
    
    var segmentos = [Segmento]()
    var estados = [Estado]()
    var cidades = [Cidade]()
    var segId: Int = 0
    var estadoId: Int = 0
    var telefone1: String = ""
    var telefone2: String = ""
    
    @IBAction func btSearch(sender: AnyObject) {
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
    
    @IBOutlet weak var txtNome: UITextField!
    @IBOutlet weak var txtDescricao: UITextField!
    @IBOutlet weak var txtResponsavel: UITextField!
    @IBOutlet weak var txtEstado: UITextField!
    @IBOutlet weak var txtCidade: UITextField!
    @IBOutlet weak var txtEndereco: UITextField!
    @IBOutlet weak var txtNumero: UITextField!
    @IBOutlet weak var txtBairro: UITextField!
    @IBOutlet weak var txtComplemento: UITextField!
    @IBOutlet weak var txtTelefone1: AKMaskField!
    @IBOutlet weak var txtTelefone2: AKMaskField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtSite: UITextField!
    @IBOutlet weak var checkPremium: CheckBox!
    @IBOutlet weak var txtSegmento: UITextField!
    
    @IBAction func btSubmit(sender: AnyObject) {
        if isEmpty() {
            let alert = UIAlertController(title: "Atenção",
                                          message: "Existem campos obrigatórios em branco!",
                                          preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            if checkPremium.isChecked {
                if contain() {
                    add(1, isDiferente: false)
                } else {
                    add(1, isDiferente: true)
                }
            } else {
                if contain() {
                    add(0, isDiferente: false)
                } else {
                    add(0, isDiferente: true)
                }
            }
        }
    }
    
    let pickerSegs = UIPickerView()
    let pickerEstados = UIPickerView()
    let pickerCidades = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getSegmentos()
        getEstados()
        
        pickerSegs.delegate = self
        pickerSegs.dataSource = self
        pickerSegs.tag = 1
        txtSegmento.inputView = pickerSegs
        
        pickerEstados.delegate = self
        pickerEstados.dataSource = self
        pickerEstados.tag = 2
        txtEstado.inputView = pickerEstados
        
        pickerCidades.delegate = self
        pickerCidades.dataSource = self
        pickerCidades.tag = 3
        txtCidade.inputView = pickerCidades
    
        txtTelefone1.maskDelegate = self
        txtTelefone2.maskDelegate = self
    }
    
    func maskFieldDidEndEditing(maskField: AKMaskField){
        var x: Int = 0
        if maskField.text != "" {
            for c in (maskField.text?.characters)! {
                if c == "_" {
                    x += 1
                }
            }
            if x == 1 {
                maskField.setMask("({dd}) {dddd}-{dddd}", withMaskTemplate: "(__) ____-____")
            }
        }
    }
    
    func maskFieldDidBeginEditing(maskField: AKMaskField) {
        maskField.setMask("({dd}) {ddddd}-{dddd}", withMaskTemplate: "(__) _____-____")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "menuPesquisa" {
            let pesquisaVC: PesquisaVC = segue.destinationViewController as! PesquisaVC
            pesquisaVC.receivedCitySigla = receivedCitySigla
            pesquisaVC.receivedCity = receivedCity
            pesquisaVC.receivedId = receivedId
        }
    }
    
    func getSegmentos() {
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, getSegmentosURL, parameters: ["android": "android"])
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
        }
    }
    
    func getEstados() {
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, getEstadosURL, parameters: ["android": "android"])
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    if json.count == 0 {
                        SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                    }
                    for i in 0...json.count {
                        let estado = Estado()
                        estado.id = json[i]["id"].stringValue
                        estado.nome = json[i]["nome"].stringValue
                        self.estados.append(estado)
                    }
                    SwiftSpinner.hide()
                }
        }
    }
    
    func getCidades(id: Int) {
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, getCidadesURL, parameters: ["android": "android", "id": id])
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    if json.count == 0 {
                        SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                    }
                    for i in 0...json.count {
                        let cidade = Cidade()
                        cidade.id = json[i]["id"].stringValue
                        cidade.nome = json[i]["nome"].stringValue
                        self.cidades.append(cidade)
                    }
                    SwiftSpinner.hide()
                }
        }
    }
    
    func add(checked: Int, isDiferente: Bool) {
        telefone1 = txtTelefone1.text!
        telefone1 = replace(telefone1)
        telefone2 = txtTelefone2.text!
        telefone2 = replace(telefone1)
        
        SwiftSpinner.show("Carregando...")
        
        if isDiferente == false {
            Alamofire.request(.POST, addURL, parameters: ["android": "android", "segmento_id": segId, "nome": txtNome.text!, "apresentacao": txtDescricao.text!, "nomeResponsavel": txtResponsavel.text!, "endereco": txtEndereco.text!, "numero": txtNumero.text!, "complemento": txtComplemento.text!, "bairro": txtBairro.text!, "telefone1": telefone1, "telefone2": telefone2, "email": txtEmail.text!, "site": txtSite.text!, "cidade": txtCidade.text!, "estado_id": estadoId, "wantsPremium": checked])
                .responseString { response in
                    if response.result.value == "sucesso" {
                        SwiftSpinner.hide()
                        let alert = UIAlertController(title: "Parabéns",
                            message: "Sua empresa foi cadastrada com sucesso!",
                            preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                        alert.addAction(ok)
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.txtSegmento.text = ""
                        self.txtSite.text = ""
                        self.txtEmail.text = ""
                        self.txtTelefone1.text = ""
                        self.txtTelefone2.text = ""
                        self.txtComplemento.text = ""
                        self.txtBairro.text = ""
                        self.txtNumero.text = ""
                        self.txtEndereco.text = ""
                        self.txtEstado.text = ""
                        self.txtResponsavel.text = ""
                        self.txtDescricao.text = ""
                        self.txtNome.text = ""
                        self.txtCidade.text = ""
                        self.txtEndereco.text = ""
                        self.txtEndereco.text = ""
                    } else {
                        SwiftSpinner.hide()
                        let alert = UIAlertController(title: "Ops..",
                            message: "Ocorreu algum erro, tente novamente",
                            preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                        alert.addAction(ok)
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
            }
        } else {
            Alamofire.request(.POST, addURL, parameters: ["android": "android", "segmento_id": segId, "nome": txtNome.text!, "apresentacao": txtDescricao.text!, "nomeResponsavel": txtResponsavel.text!, "endereco": txtEndereco.text!, "numero": txtNumero.text!, "complemento": txtComplemento.text!, "bairro": txtBairro.text!, "telefone1": telefone1, "telefone2": telefone2, "email": txtEmail.text!, "site": txtSite.text!, "cidade": txtCidade.text!, "estado_id": estadoId, "wantsPremium": checked, "isDiferente": ""])
                .responseString { response in
                    if response.result.value == "sucesso" {
                        SwiftSpinner.hide()
                        let alert = UIAlertController(title: "Parabéns",
                            message: "Sua empresa foi cadastrada com sucesso!",
                            preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                        alert.addAction(ok)
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.txtSegmento.text = ""
                        self.txtSite.text = ""
                        self.txtEmail.text = ""
                        self.txtTelefone1.text = ""
                        self.txtTelefone2.text = ""
                        self.txtComplemento.text = ""
                        self.txtBairro.text = ""
                        self.txtNumero.text = ""
                        self.txtEndereco.text = ""
                        self.txtEstado.text = ""
                        self.txtResponsavel.text = ""
                        self.txtDescricao.text = ""
                        self.txtNome.text = ""
                        self.txtCidade.text = ""
                        self.txtEndereco.text = ""
                        self.txtEndereco.text = ""
                    } else {
                        SwiftSpinner.hide()
                        let alert = UIAlertController(title: "Ops..",
                            message: "Ocorreu algum erro, tente novamente",
                            preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                        alert.addAction(ok)
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
            }
        }
    }
    
    func contain() -> Bool {
        for i in 0...cidades.count {
            if cidades[i].nome == txtCidade.text {
                return true
            }
        }
        return false
    }
    
    func replace(string: String) -> String {
        var result: String = string
        result.removeAtIndex(string.startIndex)
        result.removeAtIndex(string.startIndex.advancedBy(2))
        
        return result
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
        case 1:
            return segmentos.count
        case 2:
            return estados.count
        case 3:
            return cidades.count
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView.tag {
        case 1:
            txtSegmento.text = segmentos[row].nome
            segId = Int(segmentos[row].id)!
            break
        case 2:
            txtEstado.text = estados[row].nome
            txtCidade.enabled = true
            getCidades(Int(estados[row].id)!)
            estadoId = Int(estados[row].id)!
            break
        case 3:
            txtCidade.text = cidades[row].nome
            break
        default:
            break
        }
        
        self.view.endEditing(true)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView.tag {
        case 1:
            return segmentos[row].nome
        case 2:
            return estados[row].nome
        case 3:
            return cidades[row].nome
        default:
            return ""
        }
    }
    
    @IBAction func btBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func isEmpty() -> Bool {
        if (txtSegmento.text?.isEmpty)! || (txtNome.text?.isEmpty)! || (txtCidade.text?.isEmpty)! ||
            (txtEstado.text?.isEmpty)! || (txtBairro.text?.isEmpty)! || (txtEndereco.text?.isEmpty)!
            || (txtTelefone1.text?.isEmpty)! {
            return true
        }
        
        return false
    }
}
