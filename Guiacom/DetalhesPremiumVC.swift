//
//  DetalhesPremiumVC.swift
//  Guiacom
//
//  Created by José Cassimiro on 16/06/16.
//  Copyright © 2016 Guiacom Manhuaçu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import MapKit
import SwiftSpinner

class DetalhesPremiumVC: UIViewController, UIGestureRecognizerDelegate {

    let imgURL = "http://guiacomdigital.com.br/site/app/webroot/img/"
    let getCidadeURL = "http://guiacomdigital.com.br/webservice/getCidadeNome.php"
    let getEstadoURL = "http://guiacomdigital.com.br/webservice/getEstado.php"
    let latLongURL = "http://guiacomdigital.com.br/webservice/latLong.php"
    
    var receivedCitySigla: String = ""
    var receivedCity: String = ""
    var receivedId: String = ""
    
    @IBOutlet weak var lbNome: UILabel!
    @IBOutlet weak var descricao: UILabel!
    @IBOutlet weak var bairro: UILabel!
    @IBOutlet weak var cidade: UILabel!
    @IBOutlet weak var estado: UILabel!
    @IBOutlet weak var site: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var endereco: UILabel!
    @IBOutlet weak var telefone: UILabel!
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var telefone2: UILabel!
    
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
    
    let width: CGFloat = UIScreen.mainScreen().bounds.width
    
    var empresa = Empresa()
    var address: String = ""
    var lat: String = ""
    var long: String = ""
    
    @IBAction func btBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btLoc(sender: AnyObject) {
        dialog(5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCidade()
        
        lbNome.text = empresa.nome
        descricao.text = empresa.apresentacao
        bairro.text = empresa.bairro
        endereco.text = empresa.endereco + ", " + empresa.numero
        telefone.text = empresa.telefone1
        if (telefone.text!.containsString("\0")) {
            self.telefone.text = self.telefone.text!.stringByReplacingOccurrencesOfString("\0", withString: "")
        }
        site.text = "Não informado"
        email.text = "Não informado"
        
        let img = NSURL(string: imgURL + empresa.logo)
        let logo = UIImageView()
        logo.af_setImageWithURL(img!)
        logo.frame = CGRectMake(5, 20, width/2, width/2)
        scroll.addSubview(logo)
        
        if empresa.numero == "" {
            endereco.text = empresa.endereco + ", s/n"
        }
        
        if empresa.site != "" {
            site.text = empresa.site
            
            let tapSite:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetalhesPremiumVC.clickSite(_:)))
            site.addGestureRecognizer(tapSite)
            tapSite.delegate = self
        }
        
        if empresa.email != "" {
            email.text = empresa.email
            
            let tapEmail:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetalhesPremiumVC.clickEmail(_:)))
            email.addGestureRecognizer(tapEmail)
            tapEmail.delegate = self
        }
        
        if empresa.telefone2 != "" {
            telefone2.text = empresa.telefone2
            if (telefone2.text!.containsString("\0")) {
                self.telefone2.text = self.telefone2.text!.stringByReplacingOccurrencesOfString("\0", withString: "")
            }
            
            let tapTel2:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetalhesPremiumVC.clickTel2(_:)))
            telefone2.addGestureRecognizer(tapTel2)
            tapTel2.delegate = self
        }
        
        let tapTel:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetalhesPremiumVC.clickTel(_:)))
        telefone.addGestureRecognizer(tapTel)
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
        case 5:
            message = "Deseja abrir o Maps?"
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
                if let url = NSURL(string: "tel://\(self.telefone.text)") {
                    UIApplication.sharedApplication().openURL(url)
                }
            case 2:
                if let url = NSURL(string: "tel://\(self.telefone2.text)") {
                    UIApplication.sharedApplication().openURL(url)
                }
            case 3:
                if let url = NSURL(string: "http://" + self.site.text!) {
                    UIApplication.sharedApplication().openURL(url)
                }
            case 4:
                if let url = NSURL(string: "mailto://\(self.email.text)") {
                    UIApplication.sharedApplication().openURL(url)
                }
            case 5:
                if let url = NSURL(string: "http://maps.google.com/maps?saddr=&daddr="
                                        + self.lat + "," + self.long + "&zoom=18") {
                    UIApplication.sharedApplication().openURL(url)
                }
            default:
                message = ""
            }
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func getCidade(){
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, getCidadeURL, parameters: ["android": "android", "cidade_id": Int(empresa.cidade_id)!])
            .responseString { response in
                if let value = response.result.value {
                    self.cidade.text = value
                    
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
                                self.estado.text = json[0]["nome"].stringValue
                                
                                self.address = self.estado.text! + " " + self.cidade.text! + " " + self.empresa.endereco
                                if self.empresa.numero != "" {
                                    self.address += " " + self.empresa.numero
                                }
                                self.getLatLong(self.address)
                            }
                    }
                }
        }
    }
    
    func getLatLong(address: String){
        Alamofire.request(.POST, latLongURL, parameters: ["android": "android", "address": address])
            .responseJSON { response in
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    if json.count == 0 {
                        SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                    }
                    self.lat = json[0].stringValue
                    self.long = json[1].stringValue
                    
                    let initialLocation = CLLocation(latitude: Double(self.lat)!, longitude: Double(self.long)!)
                    self.centerMapOnLocation(initialLocation)
                    
                    SwiftSpinner.hide()
                }
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 100
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        map.setRegion(coordinateRegion, animated: true)
        
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = location.coordinate
        dropPin.title = empresa.nome
        map.addAnnotation(dropPin)
    }
}
