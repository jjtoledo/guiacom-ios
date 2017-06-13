//
//  PesquisaVC.swift
//  Guiacom
//
//  Created by José Cassimiro on 05/06/16.
//  Copyright © 2016 Guiacom Manhuaçu. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner

class PesquisaVC: UIViewController, UITableViewDataSource, UITableViewDelegate,
                    UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {

    let listaEmpresasURL = "http://guiacomdigital.com.br/webservice/listaEmpresasEmCidade.php"
    let searchEmpresasURL = "http://guiacomdigital.com.br/webservice/pesquisaEmpresasEmCidade.php"
    let estadoURL = "http://guiacomdigital.com.br/webservice/getEstado.php"
    let citiesURL = "http://guiacomdigital.com.br/webservice/listaCidadesPossuemEmpresas.php"
    let detalhesURL = "http://guiacomdigital.com.br/webservice/getDetalhes.php"
    let fotosURL = "http://guiacomdigital.com.br/webservice/getFotos.php"
    let checkPremiumURL = "http://guiacomdigital.com.br/webservice/checkCidadePossuiEmpresaPremium.php"
    let imgURL = "http://guiacomdigital.com.br/site/app/webroot/img/"
    var empresas = [Empresa]()
    var empresa = Empresa()
    var cidades = [String]()
    var cidadesId = [String]()
    var cidade: String = ""
    var cidadeId: String = ""
    var cidadeSigla: String = ""
    var estado: String = ""
    let width: CGFloat = UIScreen.mainScreen().bounds.width
    var larg1: CGFloat = 0.0
    var larg2: CGFloat = 0.0
    var logo: UIImageView!
    var text: UILabel!
    
    @IBOutlet weak var marginTop: NSLayoutConstraint!
    
    @IBAction func btBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btSearch(sender: AnyObject) {
        searchEmpresas()
    }
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lbCityName: UILabel!
    
    var receivedCitySigla: String = ""
    var receivedCity: String = ""
    var receivedId: String = ""
    
    var alertView: UIAlertController!
    
    @IBOutlet weak var listaEmpresas: UITableView!
    
    @IBAction func btTrocaCidade(sender: AnyObject) {
        createAlertView()
    }
    
    @IBAction func btCadastro(sender: AnyObject) {
        performSegueWithIdentifier("menuCadastro", sender: self)
    }   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbCityName.text = receivedCitySigla
        
        listaEmpresas.dataSource = self
        listaEmpresas.delegate = self
        
        larg1 = width/3-2
        larg2 = larg1*2
        
        if logo != nil {
            logo.removeFromSuperview()
            text.removeFromSuperview()
            marginTop.constant = 14
        }
        
        checkPremium()
        getEmpresas()
        getCidades()
    }
    
    func checkPremium() {
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, checkPremiumURL, parameters: ["android": "android", "cidade_id": receivedId])
            .responseString { response in
                if let value = response.result.value {
                    if value == "n" {
                        self.getFotos()
                    } else {
                        SwiftSpinner.hide()
                    }
                }
        }
    }

    func getFotos() {
        SwiftSpinner.show("Carregando...")
        var json: JSON = ""
        Alamofire.request(.POST, fotosURL, parameters: ["android": "android", "cidade_id": receivedId])
            .responseJSON { response in
                if let value = response.result.value {
                    json = JSON(value)
                    
                    let foto = Foto()
                    foto.foto = json[0]["foto"].stringValue
                    
                    if foto.foto != "" {
                        self.addFotoDetalhe(self.larg1/2.1, y:75, width: self.larg1*0.6, height: self.larg1*0.6, url: foto.foto)
                    }
                    SwiftSpinner.hide()
                }
        }
    }
    
    func addFotoDetalhe(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, url: String) {
        logo = UIImageView()
        logo.userInteractionEnabled = true
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickDetalhe(_:)))
        logo.addGestureRecognizer(tap)
        tap.delegate = self
        
        logo.af_setImageWithURL(NSURL(string: imgURL + url)!)
        logo.frame = CGRectMake(x, y, width, height)
        logo.layer.cornerRadius = logo.frame.height / 2.0
        logo.layer.masksToBounds = true
        
        text = UILabel()
        text.text = "Conheça a história da cidade"
        text.font = text.font.fontWithSize(11)
        text.textColor = UIColor.darkGrayColor()
        text.userInteractionEnabled = true
        
        let tap1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickDetalhe(_:)))
        text.addGestureRecognizer(tap1)
        tap1.delegate = self
        
        text.frame = CGRectMake(x*2.5, y+self.larg1*0.15, self.larg2, self.larg1*0.3)
        
        self.marginTop.constant = 80
        self.view.addSubview(logo)
        self.view.addSubview(text)
    }
    
    func clickDetalhe(gr: UIGestureRecognizer) {
        self.performSegueWithIdentifier("detalhesCidade", sender: self)
    }

    
    func getEmpresas() {
        var json: JSON = ""
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, listaEmpresasURL, parameters: ["android": "android", "id": receivedId])
            .responseJSON { response in
                if let value = response.result.value {
                    json = JSON(value)
                    
                    if json.count == 0 {
                        SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                    }
                    self.empresas.removeAll()
                    for i in 0...json.count{
                        let empresa = Empresa()
                        empresa.apresentacao = json[i]["apresentacao"].stringValue
                        empresa.bairro = json[i]["bairro"].stringValue
                        empresa.cidade_id = json[i]["cidade_id"].stringValue
                        empresa.cidade_nome = json[i]["cidade_nome"].stringValue
                        empresa.complemento = json[i]["complemento"].stringValue
                        empresa.email = json[i]["email"].stringValue
                        empresa.endereco = json[i]["endereco"].stringValue
                        empresa.logo = json[i]["logo"].stringValue
                        empresa.nome = json[i]["nome"].stringValue
                        empresa.nomeResponsavel = json[i]["nomeResponsavel"].stringValue
                        empresa.numero = json[i]["numero"].stringValue
                        empresa.pendente = json[i]["pendente"].stringValue
                        empresa.segmento_id = json[i]["segmento_id"].stringValue
                        empresa.segmento_nome = json[i]["segmento_nome"].stringValue
                        empresa.site = json[i]["site"].stringValue
                        empresa.telefone1 = json[i]["telefone1"].stringValue
                        empresa.telefone2 = json[i]["telefone2"].stringValue
                        empresa.tipoCadastro = json[i]["tipoCadastro"].stringValue
                        empresa.wantsPremium = json[i]["wantsPremium"].stringValue
                        self.empresas.append(empresa)
                    }
                }
                self.listaEmpresas.reloadData()
                SwiftSpinner.hide()
        }
    }
    
    func searchEmpresas() {
        var json: JSON = ""
        SwiftSpinner.show("Pesquisando empresas...")
        Alamofire.request(.POST, searchEmpresasURL, parameters: ["android": "android", "id_cidade": receivedId, "empresa": txtSearch.text!])
            .responseJSON { response in
                if let value = response.result.value {
                    json = JSON(value)
                    
                    self.empresas.removeAll()
                    for i in 0...json.count{
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
                        empresa.segmento_nome = json[i]["segmento_nome"].stringValue
                        empresa.site = json[i]["site"].stringValue
                        empresa.telefone1 = json[i]["telefone1"].stringValue
                        empresa.telefone2 = json[i]["telefone2"].stringValue
                        empresa.tipoCadastro = json[i]["tipoCadastro"].stringValue
                        self.empresas.append(empresa)
                    }
                } else {
                    let alert = UIAlertController(title: "Ops..",
                        message: "Não encontramos nenhuma empresa, tente novamente",
                        preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
                    alert.addAction(ok)
                    
                    self.presentViewController(alert, animated: true, completion: nil)

                }
                self.listaEmpresas.reloadData()
                SwiftSpinner.hide()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "menuSegmentos" {
            let segmentosVC: SegmentosVC = segue.destinationViewController as! SegmentosVC
            segmentosVC.receivedCitySigla = self.receivedCitySigla
            segmentosVC.receivedCity = self.receivedCity
            segmentosVC.receivedId = self.receivedId
        } else if segue.identifier == "menuMain" {
            let mainVC: ViewController = segue.destinationViewController as! ViewController
            mainVC.cidadeId = self.receivedId
            mainVC.cidade = self.receivedCity
            alertView.dismissViewControllerAnimated(true, completion: nil)
        } else if segue.identifier == "menuDetalhes" {
            let detalhesVC: DetalhesVC = segue.destinationViewController as! DetalhesVC
            detalhesVC.empresa = self.empresa
            detalhesVC.receivedCitySigla = self.receivedCitySigla
            detalhesVC.receivedCity = self.receivedCity
            detalhesVC.receivedId = self.receivedId
        } else if segue.identifier == "menuDetalhesPremium" {
            let detalhesPremiumVC: DetalhesPremiumVC = segue.destinationViewController as! DetalhesPremiumVC
            detalhesPremiumVC.empresa = self.empresa
            detalhesPremiumVC.receivedCitySigla = self.receivedCitySigla
            detalhesPremiumVC.receivedCity = self.receivedCity
            detalhesPremiumVC.receivedId = self.receivedId
        } else if segue.identifier == "menuCadastro" {
            let cadastroVC: CadastroViewController = segue.destinationViewController as! CadastroViewController
            cadastroVC.receivedCitySigla = self.receivedCitySigla
            cadastroVC.receivedCity = self.receivedCity
            cadastroVC.receivedId = self.receivedId
        } else if segue.identifier == "detalhesCidade" {
            let dcVC: DetalhesCidadeVC = segue.destinationViewController as! DetalhesCidadeVC
            dcVC.receivedCitySigla = self.lbCityName.text!
            dcVC.receivedCity = self.receivedCity
            dcVC.receivedId = self.receivedId
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return empresas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: EmpresaCell = tableView.dequeueReusableCellWithIdentifier("Empresa") as! EmpresaCell
        
        cell.segmento.text = empresas[indexPath.row].segmento_nome
        cell.fone.text = empresas[indexPath.row].telefone1
        if ((cell.fone.text?.containsString("\0")) != nil) {
            cell.fone.text = cell.fone.text?.stringByReplacingOccurrencesOfString("\0", withString: "")
        }
        cell.nome.text = empresas[indexPath.row].nome
        
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
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cidades.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.receivedCity = cidades[row]
        self.receivedId = cidadesId[row]
        getEstado()
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
    
    func sigla(estado: String) -> String {
        switch estado {
        case "Minas Gerais":
            return "MG"
        case "Espírito Santo":
            return "ES"
        case "Amazonas":
            return "AM"
        case "Rio de Janeiro":
            return "RJ"
        case "São Paulo":
            return "SP"
        case "Rio Grande do Sul":
            return "RS"
        default:
            return ""
        }
    }
    
    func getEstado() {
        var json: JSON = ""
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, estadoURL, parameters: ["android": "android", "cidade_id": self.receivedId])
            .responseJSON { response in
                if let value = response.result.value {
                    json = JSON(value)
                    
                    if json.count == 0 {
                        SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                    }
                    
                    self.estado = self.sigla(json[0]["nome"].stringValue)
                    self.cidadeSigla = self.receivedCity + " - " + self.estado
                   
                    self.receivedCitySigla = self.cidadeSigla
                    self.cidade = self.receivedCity
                    self.cidadeId = self.receivedId
                    
                    Alamofire.request(.POST, self.checkPremiumURL, parameters: ["android": "android", "cidade_id": self.receivedId])
                        .responseString { response in
                            if let value = response.result.value {
                                if value == "n" {
                                    self.viewDidLoad()
                                    self.dismissViewControllerAnimated(true, completion: nil)
                                    SwiftSpinner.hide()
                                } else {
                                    SwiftSpinner.hide()
                                    self.performSegueWithIdentifier("menuMain", sender: self)
                                }
                            }
                    }
                }
        }
    }
}
