//
//  DetalhesVC.swift
//  Guiacom
//
//  Created by José Cassimiro on 16/06/16.
//  Copyright © 2016 Guiacom Manhuaçu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner

class DetalhesVC: UIViewController, UIGestureRecognizerDelegate {

    let getCidadeURL = "http://guiacomdigital.com.br/webservice/getCidadeNome.php"
    let getEstadoURL = "http://guiacomdigital.com.br/webservice/getEstado.php"
    
    var receivedCitySigla: String = ""
    var receivedCity: String = ""
    var receivedId: String = ""
    
    @IBOutlet weak var lbNome: UILabel!
    @IBOutlet weak var lbDescricao: UILabel!
    @IBOutlet weak var lbTelefone: UILabel!
    @IBOutlet weak var lbEndereco: UILabel!
    @IBOutlet weak var lbBairro: UILabel!
    @IBOutlet weak var lbCidade: UILabel!
    @IBOutlet weak var lbEstado: UILabel!
    @IBOutlet weak var lbSite: UILabel!
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var lbTelefone2: UILabel!
    
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
    
    var cidade: String = ""
    var estado: String = ""
    var empresa = Empresa()
    
    @IBAction func btBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCidade()

        lbNome.text = empresa.nome
        lbDescricao.text = empresa.apresentacao
        lbTelefone.text = empresa.telefone1
        if (lbTelefone.text!.containsString("\0")) {
            self.lbTelefone.text = self.lbTelefone.text!.stringByReplacingOccurrencesOfString("\0", withString: "")
        }
        
        lbEndereco.text = empresa.endereco + ", " + empresa.numero
        lbBairro.text = empresa.bairro
        lbSite.text = "Não informado"
        lbEmail.text = "Não informado"
        
        if empresa.numero == "" {
            lbEndereco.text = empresa.endereco + ", s/n"
        }
        
        if empresa.site != "" {
            lbSite.text = empresa.site
            
            let tapSite:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetalhesPremiumVC.clickSite(_:)))
            lbSite.addGestureRecognizer(tapSite)
            tapSite.delegate = self
        }
        
        if empresa.email != "" {
            lbEmail.text = empresa.email
            
            let tapEmail:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetalhesPremiumVC.clickEmail(_:)))
            lbEmail.addGestureRecognizer(tapEmail)
            tapEmail.delegate = self
        }
        
        if empresa.telefone2 != "" {
            lbTelefone2.text = empresa.telefone2
            if (lbTelefone2.text!.containsString("\0")) {
                self.lbTelefone2.text = self.lbTelefone.text!.stringByReplacingOccurrencesOfString("\0", withString: "")
            }
            
            let tapTel2:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetalhesPremiumVC.clickTel2(_:)))
            lbTelefone2.addGestureRecognizer(tapTel2)
            tapTel2.delegate = self
        }
        
        let tapTel:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetalhesPremiumVC.clickTel(_:)))
        lbTelefone.addGestureRecognizer(tapTel)
        tapTel.delegate = self
    }
    
    func clickTel(gr:UITapGestureRecognizer) {
        dialog(1)
    }
    
    func clickTel2(gr:UITapGestureRecognizer) {
        dialog(2)
    }
    
    func clickSite(gr:UITapGestureRecognizer) {
        dialog(3)
    }
    
    func clickEmail(gr:UITapGestureRecognizer) {
        dialog(4)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "menuPesquisa" {
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

    func getCidade(){
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, getCidadeURL, parameters: ["android": "android", "cidade_id": Int(empresa.cidade_id)!])
            .responseString { response in
                if let value = response.result.value {
                    self.cidade = value
                    
                    if value.characters.count == 0 {
                        SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                    }
                    Alamofire.request(.POST, self.getEstadoURL, parameters: ["android": "android", "cidade_id": Int(self.empresa.cidade_id)!])
                        .responseJSON { response in
                            if let value = response.result.value {
                                let json = JSON(value)
                                
                                if json.count == 0 {
                                    SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                                }
                                self.estado = json[0]["nome"].stringValue
                                self.lbCidade.text = self.cidade
                                self.lbEstado.text = self.estado
                                
                                SwiftSpinner.hide()
                            }
                    }
                }
        }
    }
    
    func dialog(tipo: Int) {
        var message: String = ""
        
        switch tipo {
        case 1:
            message = "Deseja fazer a ligação?"
        case 2:
            message = "Deseja fazer a ligação?"
        case 3:
            message = "Deseja abrir este site?"
        case 4:
            message = "Deseja enviar um email?"
        default:
            message = ""
        }
        
        let alert = UIAlertController(title: "Atenção",
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Não", style: .Cancel, handler: { (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Sim", style: .Default, handler: { (action: UIAlertAction!) in
            switch tipo {
            case 1:
                if let url = NSURL(string: "tel://\(self.lbTelefone.text)") {
                    UIApplication.sharedApplication().openURL(url)
                }
            case 2:
                if let url = NSURL(string: "tel://\(self.lbTelefone2.text)") {
                    UIApplication.sharedApplication().openURL(url)
                }
            case 3:
                if let url = NSURL(string: "http://" + self.lbSite.text!) {
                    UIApplication.sharedApplication().openURL(url)
                }
            case 4:
                if let url = NSURL(string: "mailto://\(self.lbEmail.text)") {
                    UIApplication.sharedApplication().openURL(url)
                }
            default:
                message = ""
            }
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
