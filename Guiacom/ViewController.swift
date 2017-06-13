//
//  ViewController.swift
//  Guiacom
//
//  Created by José Cassimiro on 30/05/16.
//  Copyright © 2016 Guiacom Manhuaçu. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftSpinner

extension CollectionType {
    /// Return a copy of `self` with its elements shuffled
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension MutableCollectionType where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffleInPlace() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {
    
    let citiesURL = "http://guiacomdigital.com.br/webservice/listaCidadesPossuemEmpresas.php"
    let estadoURL = "http://guiacomdigital.com.br/webservice/getEstado.php"
    let empresasURL = "http://guiacomdigital.com.br/webservice/listaEmpresasPremiumEmCidade.php"
    let imgURL = "http://guiacomdigital.com.br/site/app/webroot/img/"
    let fotosURL = "http://guiacomdigital.com.br/webservice/getFotos.php"
    
    var logo: UIImageView!
    var btnSearch: UIImageView!
    var text: UILabel!
    var cidades = [String]()
    var cidadesId = [String]()
    var cidadeSigla: String = ""
    var cidade: String = ""
    var cidadeId: String = ""
    var estado: String = ""
    var empresas = [Empresa]()
    var premium1 = [Empresa]()
    var premium2 = [Empresa]()
    let width: CGFloat = UIScreen.mainScreen().bounds.width
    var larg1: CGFloat = 0.0
    var larg2: CGFloat = 0.0
    var logos = [String]()
    var empresasMosaico = [Empresa]()
    var empresa = Empresa()
    var logoImages = [UIImageView]()
    var tipo = [Int](arrayLiteral: 1,1,1,2,1,1,1,2,1,
                     1,1,1,1,1,2,2,1,1,
                     1,1,2,1,1,1,2,1,1,
                     1,1,1,1,1,2,2,1,1,
                     2,1,1,1,1,1,1,1,
                     2,1,1,1,2,1,1,1,2,
                     1,1,1,1,1,1,2,2,1,
                     1,1,1,2,1,1,1,2,1,
                     1,1,1,1,1,1,2,2,1,
                     1,2,1,1,1,1,1,1,
                     1,2)
    
    @IBOutlet weak var lbCidades: UILabel!
    @IBOutlet weak var cidadesTop: NSLayoutConstraint!
    @IBOutlet weak var searchTop: NSLayoutConstraint!
    @IBOutlet weak var citySelect: UITextField!
    @IBOutlet weak var lbCity: UILabel!
    @IBOutlet weak var lbPremium: UILabel!
    @IBOutlet weak var ivLine: UIImageView!
    @IBOutlet weak var semEmpresas: UITextView!
    @IBOutlet weak var mosaico: UIScrollView!
    
    @IBAction func btContato(sender: AnyObject) {
        self.performSegueWithIdentifier("menuContato", sender: self)
    }
    
    @IBAction func btSobre(sender: AnyObject) {
        self.performSegueWithIdentifier("menuSobre", sender: self)
    }
    
    let picker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mosaico.contentSize = CGSize(width: width, height: 6000)
        mosaico.hidden = true
        semEmpresas.hidden = true
        
        larg1 = width/3-2
        larg2 = (width/3-2)*2+3
        
        getCidades()
        picker.delegate = self
        picker.dataSource = self
        citySelect.inputView = picker
        
        if cidade != "" && cidadeId != ""{
            getEstado2(cidadeId)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .ScaleAspectFit
        
        let image = UIImage(named: "ic_logo_topo")
        imageView.image = image
        
        navigationItem.titleView = imageView
    }
    
    @IBAction func menuPesquisa(sender: UIBarButtonItem) {
        if citySelect.text == ""{
            let alert = UIAlertController(title: "Atenção",
                                          message: "Selecione uma cidade primeiro!",
                                          preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)
            alert.addAction(ok)
            
            presentViewController(alert, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("menuPesquisa", sender: self)
        }
    }
    
    @IBAction func btCadastro(sender: AnyObject) {
        performSegueWithIdentifier("menuCadastro", sender: self)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cidades.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cidade = cidades[row]
        
        for subview in self.mosaico.subviews {
            subview.removeFromSuperview()
        }
        
        SwiftSpinner.show("Carregando...")
        getEstado(cidadesId[row], row: row)
        self.view.endEditing(true)
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cidades[row]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "menuPesquisa" {
            let pesquisaVC: PesquisaVC = segue.destinationViewController as! PesquisaVC
            pesquisaVC.receivedCitySigla = citySelect.text!
            pesquisaVC.receivedCity = cidade
            pesquisaVC.receivedId = cidadeId
        } else if segue.identifier == "menuCadastro" {
            let cadastroVC: CadastroViewController = segue.destinationViewController as! CadastroViewController
            cadastroVC.receivedCitySigla = citySelect.text!
            cadastroVC.receivedCity = cidade
            cadastroVC.receivedId = cidadeId
        } else if segue.identifier == "menuDetalhesPremium" {
            let detalhesPremiumVC: DetalhesPremiumVC = segue.destinationViewController as! DetalhesPremiumVC
            detalhesPremiumVC.empresa = self.empresa
            detalhesPremiumVC.receivedCitySigla = citySelect.text!
            detalhesPremiumVC.receivedCity = cidade
            detalhesPremiumVC.receivedId = cidadeId
        } else if segue.identifier == "menuContato" {
            let contatoVC: ContatoVC = segue.destinationViewController as! ContatoVC
            contatoVC.receivedCitySigla = self.citySelect.text!
            contatoVC.receivedCity = cidade
            contatoVC.receivedId = cidadeId
        } else if segue.identifier == "menuSobre" {
            let sobreVC: SobreVC = segue.destinationViewController as! SobreVC
            sobreVC.receivedCitySigla = self.citySelect.text!
            sobreVC.receivedCity = cidade
            sobreVC.receivedId = cidadeId
        } else if segue.identifier == "detalhesCidade" {
            let dcVC: DetalhesCidadeVC = segue.destinationViewController as! DetalhesCidadeVC
            dcVC.receivedCitySigla = self.citySelect.text!
            dcVC.receivedCity = cidade
            dcVC.receivedId = cidadeId
        }
    }
    
    func getEstado(id: String, row: Int) {
        var json: JSON = ""
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, estadoURL, parameters: ["android": "android", "cidade_id": id])
            .responseJSON { response in
                if let value = response.result.value {
                    json = JSON(value)
                    
                    if json.count == 0 {
                        SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                    }
                    
                    self.estado = json[0]["nome"].stringValue
                    self.cidadeSigla = self.sigla(self.estado)
                    self.citySelect.text = self.cidades[row] + " - " + self.cidadeSigla
                    self.cidadeId = self.cidadesId[row]
                    self.lbCity.text = self.citySelect.text
                    self.lbCity.hidden = false
                    self.lbPremium.hidden = false
                    self.ivLine.hidden = false
                    self.getEmpresas()
                }
        }
    }
    
    func getEstado2(id: String) {
        var json: JSON = ""
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, estadoURL, parameters: ["android": "android", "cidade_id": id])
            .responseJSON { response in
                if let value = response.result.value {
                    json = JSON(value)
                    
                    if json.count == 0 {
                        SwiftSpinner.show("Falha ao conectar, verifique sua conexão", animated: false).addTapHandler({SwiftSpinner.hide()})
                    }
                    
                    self.estado = json[0]["nome"].stringValue
                    self.cidadeSigla = self.sigla(self.estado)
                    self.citySelect.text = self.cidade + " - " + self.cidadeSigla
                    self.lbCity.text = self.citySelect.text
                    self.lbCity.hidden = false
                    self.lbPremium.hidden = false
                    self.ivLine.hidden = false
                    self.getEmpresas()
                }
        }
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
    
    func getFotos() {
        var json: JSON = ""
        Alamofire.request(.POST, fotosURL, parameters: ["android": "android", "cidade_id": cidadeId])
            .responseJSON { response in
                if let value = response.result.value {
                    json = JSON(value)
                    
                    let foto = Foto()
                    foto.foto = json[0]["foto"].stringValue
                    
                    self.addFotoDetalhe(self.larg1/2.1, y:145, width: 67, height: 67, url: foto.foto)
                }
        }
    }
    
    func getEmpresas() {
        var json: JSON = ""
        SwiftSpinner.show("Carregando...")
        Alamofire.request(.POST, empresasURL, parameters: ["android": "android", "id": cidadeId])
            .responseJSON { response in
                if let value = response.result.value {
                    self.lbCidades.hidden = true
                    self.cidadesTop.constant = 10
                    self.searchTop.constant = self.larg1+20
                    self.addBtnSearch(20, y: 218, width: self.width-40, height: self.larg1/3)
                    self.view.layoutIfNeeded()
                    
                    self.getFotos()
                    
                    json = JSON(value)
                    	
                    self.semEmpresas.hidden = true
                    self.empresas.removeAll()
                    self.mosaico.hidden = false
                    
                    var tem = false
                    for i in 0...json.count{
                        let empresa = Empresa()
                        empresa.id = String(i)
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
                        
                        if empresa.tipoCadastro == "2" {
                            tem = true
                        }
                    }
                    
                    self.empresas.shuffleInPlace()

                    self.carregaLogos()
                    
                    if tem {
                        self.addLogo(0, y: 0, width: self.larg1, height: self.larg1, p: 0, tag: self.empresasMosaico[0].id)
                        self.addLogo(self.larg1+3, y: 0, width: self.larg1, height: self.larg1, p: 1, tag: self.empresasMosaico[1].id)
                        self.addLogo(self.larg1*2+6, y: 0, width: self.larg1, height: self.larg1, p: 2, tag: self.empresasMosaico[2].id)
                        
                        self.addLogo(0, y: self.larg1+3, width: self.larg2, height: self.larg2, p: 3, tag: self.empresasMosaico[3].id)
                        self.addLogo((self.larg1)*2+6, y: self.larg1+3, width: self.larg1, height: self.larg1, p: 4, tag: self.empresasMosaico[4].id)
                        self.addLogo((self.larg1)*2+6, y: (self.larg1)*2+6, width: self.larg1, height: self.larg1, p: 5, tag: self.empresasMosaico[5].id)
                        
                        self.addLogo(0, y: (self.larg2+self.larg1+6), width: self.larg1, height: self.larg1, p: 6, tag: self.empresasMosaico[6].id)
                        self.addLogo(self.larg1+3, y: (self.larg2+self.larg1+6), width: self.larg2, height: self.larg2, p: 7, tag: self.empresasMosaico[7].id)
                        self.addLogo(0, y: (self.larg1*2)+self.larg2+9, width: self.larg1, height: self.larg1, p: 8, tag: self.empresasMosaico[8].id)
                        
                        self.addLogo(0, y: (self.larg2*2+self.larg1+9), width: self.larg1, height: self.larg1, p: 9, tag: self.empresasMosaico[9].id)
                        self.addLogo(self.larg1+3, y: (self.larg2*2+self.larg1+9), width: self.larg1, height: self.larg1, p: 10, tag: self.empresasMosaico[10].id)
                        self.addLogo(self.larg1*2+6, y: (self.larg2*2+self.larg1+9), width: self.larg1, height: self.larg1, p: 11, tag: self.empresasMosaico[11].id)
                        
                        self.addLogo(0, y: (self.larg2*2+self.larg1*2+12), width: self.larg1, height: self.larg1, p: 12, tag: self.empresasMosaico[12].id)
                        self.addLogo(0, y: (self.larg2*2+self.larg1*3+15), width: self.larg1, height: self.larg1, p: 13, tag: self.empresasMosaico[13].id)
                        self.addLogo(self.larg1+3, y: (self.larg2*2+self.larg1*2+12), width: self.larg2, height: self.larg2, p: 14, tag: self.empresasMosaico[14].id)
                        
                        self.addLogo(0, y: (self.larg2*2+self.larg1*4+18), width: self.larg2, height: self.larg2, p: 15, tag: self.empresasMosaico[15].id)
                        self.addLogo((self.larg1)*2+6, y: (self.larg2*2+self.larg1*4+18), width: self.larg1, height: self.larg1, p: 16, tag: self.empresasMosaico[16].id)
                        self.addLogo((self.larg1)*2+6, y: (self.larg2*2+self.larg1*5+21), width: self.larg1, height: self.larg1, p: 17, tag: self.empresasMosaico[17].id)
                        
                        self.addLogo(0, y: (self.larg2*3+self.larg1*4+21), width: self.larg1, height: self.larg1, p: 18, tag: self.empresasMosaico[18].id)
                        self.addLogo(0, y: (self.larg2*3+self.larg1*5+24), width: self.larg1, height: self.larg1, p: 19, tag: self.empresasMosaico[19].id)
                        self.addLogo(self.larg1+3, y: (self.larg2*3+self.larg1*4+21), width: self.larg2, height: self.larg2, p: 20, tag: self.empresasMosaico[20].id)
                        
                        self.addLogo(0, y: (self.larg2*4+self.larg1*4+24), width: self.larg1, height: self.larg1, p: 21, tag: self.empresasMosaico[21].id)
                        self.addLogo(self.larg1+3, y: (self.larg2*4+self.larg1*4+24), width: self.larg1, height: self.larg1, p: 22, tag: self.empresasMosaico[22].id)
                        self.addLogo(self.larg1*2+6, y: (self.larg2*4+self.larg1*4+24), width: self.larg1, height: self.larg1, p: 23, tag: self.empresasMosaico[23].id)
                        
                        self.addLogo(0, y: (self.larg2*4+self.larg1*5+27), width: self.larg2, height: self.larg2, p: 24, tag: self.empresasMosaico[24].id)
                        self.addLogo((self.larg1)*2+6, y: (self.larg2*4+self.larg1*5+27), width: self.larg1, height: self.larg1, p: 25, tag: self.empresasMosaico[25].id)
                        self.addLogo((self.larg1)*2+6, y: (self.larg2*4+self.larg1*6+30), width: self.larg1, height: self.larg1, p: 26, tag: self.empresasMosaico[26].id)
                        
                        self.addLogo(0, y: (self.larg2*5+self.larg1*5+30), width: self.larg1, height: self.larg1, p: 27, tag: self.empresasMosaico[27].id)
                        self.addLogo(self.larg1+3, y: (self.larg2*5+self.larg1*5+30), width: self.larg1, height: self.larg1, p: 28, tag: self.empresasMosaico[28].id)
                        self.addLogo(self.larg1*2+6, y: (self.larg2*5+self.larg1*5+30), width: self.larg1, height: self.larg1, p: 29, tag: self.empresasMosaico[29].id)
                        
                        self.addLogo(0, y: (self.larg2*5+self.larg1*6+33), width: self.larg1, height: self.larg1, p: 30, tag: self.empresasMosaico[30].id)
                        self.addLogo(0, y: (self.larg2*5+self.larg1*7+36), width: self.larg1, height: self.larg1, p: 31, tag: self.empresasMosaico[31].id)
                        self.addLogo(self.larg1+3, y: (self.larg2*5+self.larg1*6+33), width: self.larg2, height: self.larg2, p: 32, tag: self.empresasMosaico[32].id)
                        
                        self.addLogo(0, y: (self.larg2*6+self.larg1*6+36), width: self.larg2, height: self.larg2, p: 33, tag: self.empresasMosaico[33].id)
                        self.addLogo((self.larg1)*2+6, y: (self.larg2*6+self.larg1*6+36), width: self.larg1, height: self.larg1, p: 34, tag: self.empresasMosaico[34].id)
                        self.addLogo((self.larg1)*2+6, y: (self.larg2*6+self.larg1*7+39), width: self.larg1, height: self.larg1, p: 35, tag: self.empresasMosaico[35].id)
                        
                        self.addLogo(0, y: (self.larg2*7+self.larg1*6+39), width: self.larg2, height: self.larg2, p: 36, tag: self.empresasMosaico[36].id)
                        self.addLogo((self.larg1)*2+6, y: (self.larg2*7+self.larg1*6+39), width: self.larg1, height: self.larg1, p: 37, tag: self.empresasMosaico[37].id)
                        self.addLogo((self.larg1)*2+6, y: (self.larg2*7+self.larg1*7+42), width: self.larg1, height: self.larg1, p: 38, tag: self.empresasMosaico[38].id)
                        
                        self.addLogo(0, y: (self.larg2*8+self.larg1*6+42), width: self.larg1, height: self.larg1, p: 39, tag: self.empresasMosaico[39].id)
                        self.addLogo(self.larg1+3, y: (self.larg2*8+self.larg1*6+42), width: self.larg1, height: self.larg1, p: 40, tag: self.empresasMosaico[40].id)
                        self.addLogo(self.larg1*2+6, y: (self.larg2*8+self.larg1*6+42), width: self.larg1, height: self.larg1, p: 41, tag: self.empresasMosaico[41].id)
                        
                        self.addLogo(0, y: (self.larg2*8+self.larg1*7+45), width: self.larg1, height: self.larg1, p: 42, tag: self.empresasMosaico[42].id)
                        self.addLogo(0, y: (self.larg2*8+self.larg1*8+48), width: self.larg1, height: self.larg1, p: 43, tag: self.empresasMosaico[43].id)
                        self.addLogo(self.larg1+3, y: (self.larg2*8+self.larg1*7+45), width: self.larg2, height: self.larg2, p: 44, tag: self.empresasMosaico[44].id)
                        
                        self.addLogo(0, y: (self.larg2*9+self.larg1*7+48), width: self.larg1, height: self.larg1, p: 45, tag: self.empresasMosaico[45].id)
                        self.addLogo(self.larg1+3, y: (self.larg2*9+self.larg1*7+48), width: self.larg1, height: self.larg1, p: 46, tag: self.empresasMosaico[46].id)
                        self.addLogo(self.larg1*2+6, y: (self.larg2*9+self.larg1*7+48), width: self.larg1, height: self.larg1, p: 47, tag: self.empresasMosaico[47].id)
                        
                        self.addLogo(0, y: (self.larg2*9+self.larg1*8+51), width: self.larg2, height: self.larg2, p: 48, tag: self.empresasMosaico[48].id)
                        self.addLogo((self.larg1)*2+6, y: (self.larg2*9+self.larg1*8+51), width: self.larg1, height: self.larg1, p: 49, tag: self.empresasMosaico[49].id)
                        self.addLogo((self.larg1)*2+6, y: (self.larg2*9+self.larg1*9+54), width: self.larg1, height: self.larg1, p: 50, tag: self.empresasMosaico[50].id)
                        
                        self.mosaico.contentSize = CGSize(width: self.width, height: (self.larg2*9.5+self.larg1*9+54))
                    } else {
                        self.addLogo(0, y: 0, width: self.larg1, height: self.larg1, p: 0, tag: self.empresasMosaico[0].id)
                        self.addLogo(self.larg1+3, y: 0, width: self.larg1, height: self.larg1, p: 1, tag: self.empresasMosaico[1].id)
                        self.addLogo(self.larg1*2+6, y: 0, width: self.larg1, height: self.larg1, p: 2, tag: self.empresasMosaico[2].id)
                        
                        self.addLogo(0, y: self.larg1+3, width: self.larg1, height: self.larg1, p: 3, tag: self.empresasMosaico[3].id)
                        self.addLogo(self.larg1+3, y: self.larg1+3, width: self.larg1, height: self.larg1, p: 4, tag: self.empresasMosaico[4].id)
                        self.addLogo(self.larg1*2+6, y: self.larg1+3, width: self.larg1, height: self.larg1, p: 5, tag: self.empresasMosaico[5].id)
                        
                        self.addLogo(0, y: self.larg1*2+6, width: self.larg1, height: self.larg1, p: 6, tag: self.empresasMosaico[6].id)
                        self.addLogo(self.larg1+3, y: self.larg1*2+6, width: self.larg1, height: self.larg1, p: 7, tag: self.empresasMosaico[7].id)
                        self.addLogo(self.larg1*2+6, y: self.larg1*2+6, width: self.larg1, height: self.larg1, p: 8, tag: self.empresasMosaico[8].id)
                        
                        self.addLogo(0, y: self.larg1*3+9, width: self.larg1, height: self.larg1, p: 9, tag: self.empresasMosaico[9].id)
                        self.addLogo(self.larg1+3, y: self.larg1*3+9, width: self.larg1, height: self.larg1, p: 10, tag: self.empresasMosaico[10].id)
                        self.addLogo(self.larg1*2+6, y: self.larg1*3+9, width: self.larg1, height: self.larg1, p: 11, tag: self.empresasMosaico[11].id)
                        
                        self.addLogo(0, y: self.larg1*4+12, width: self.larg1, height: self.larg1, p: 12, tag: self.empresasMosaico[12].id)
                        self.addLogo(self.larg1+3, y: self.larg1*4+12, width: self.larg1, height: self.larg1, p: 13, tag: self.empresasMosaico[13].id)
                        self.addLogo(self.larg1*2+6, y: self.larg1*4+12, width: self.larg1, height: self.larg1, p: 14, tag: self.empresasMosaico[14].id)
                        
                        self.addLogo(0, y: self.larg1*5+15, width: self.larg1, height: self.larg1, p: 15, tag: self.empresasMosaico[15].id)
                        self.addLogo(self.larg1+3, y: self.larg1*5+15, width: self.larg1, height: self.larg1, p: 16, tag: self.empresasMosaico[16].id)
                        self.addLogo(self.larg1*2+6, y: self.larg1*5+15, width: self.larg1, height: self.larg1, p: 17, tag: self.empresasMosaico[17].id)
                        
                        self.addLogo(0, y: self.larg1*6+18, width: self.larg1, height: self.larg1, p: 18, tag: self.empresasMosaico[18].id)
                        self.addLogo(self.larg1+3, y: self.larg1*6+18, width: self.larg1, height: self.larg1, p: 19, tag: self.empresasMosaico[19].id)
                        self.addLogo(self.larg1*2+6, y: self.larg1*6+18, width: self.larg1, height: self.larg1, p: 20, tag: self.empresasMosaico[20].id)
                        
                        self.addLogo(0, y: self.larg1*7+21, width: self.larg1, height: self.larg1, p: 21, tag: self.empresasMosaico[21].id)
                        self.addLogo(self.larg1+3, y: self.larg1*7+21, width: self.larg1, height: self.larg1, p: 22, tag: self.empresasMosaico[22].id)
                        self.addLogo(self.larg1*2+6, y: self.larg1*7+21, width: self.larg1, height: self.larg1, p: 23, tag: self.empresasMosaico[23].id)
                        
                        self.addLogo(0, y: self.larg1*8+24, width: self.larg1, height: self.larg1, p: 24, tag: self.empresasMosaico[24].id)
                        self.addLogo(self.larg1+3, y: self.larg1*8+24, width: self.larg1, height: self.larg1, p: 25, tag: self.empresasMosaico[25].id)
                        self.addLogo(self.larg1*2+6, y: self.larg1*8+24, width: self.larg1, height: self.larg1, p: 26, tag: self.empresasMosaico[26].id)
                        
                        self.addLogo(0, y: self.larg1*9+27, width: self.larg1, height: self.larg1, p: 27, tag: self.empresasMosaico[27].id)
                        self.addLogo(self.larg1+3, y: self.larg1*9+27, width: self.larg1, height: self.larg1, p: 28, tag: self.empresasMosaico[28].id)
                        self.addLogo(self.larg1*2+6, y: self.larg1*9+27, width: self.larg1, height: self.larg1, p: 29, tag: self.empresasMosaico[29].id)
                        
                        self.mosaico.contentSize = CGSize(width: self.width, height: (self.larg1*10+30))
                    }
                    
                    SwiftSpinner.hide()
                } else {
                    self.semEmpresas.hidden = false
                    if self.logo != nil {
                        self.lbCidades.hidden = false
                        self.cidadesTop.constant = 53
                        self.searchTop.constant = 9
                        self.btnSearch.hidden = true
                        self.logo.removeFromSuperview()
                        self.text.removeFromSuperview()
                        self.view.layoutIfNeeded()
                    }
                    SwiftSpinner.hide()
                    self.performSegueWithIdentifier("menuPesquisa", sender: self)
                }
        }
    }
    
    func carregaLogos() {
        for empresa in empresas {
            switch empresa.tipoCadastro {
            case "1":
                self.premium1.append(empresa)
            case "2":
                self.premium2.append(empresa)
            default:
                break
            }
        }
        
        var x = [Int](arrayLiteral: 0,0,0)
        var tam = 50
        if premium2.count == 0 {
            tam = 30
            for i in 0...tam {
                self.tipo[i] = 1
            }
        }
        
        for i in 0...tam {
            switch self.tipo[i] {
            case 1:
                if x[0] == self.premium1.count {
                    x[0] = 0
                    self.premium1.shuffleInPlace()
                }
                
                let img = imgURL + self.premium1[x[0]].logo
                self.logos.append(img)
                self.empresasMosaico.append(self.premium1[x[0]])
                
                x[0] += 1
            case 2:
                if x[1] == self.premium2.count {
                    x[1] = 0
                    self.premium2.shuffleInPlace()
                }
                
                let img = imgURL + self.premium2[x[1]].logo
                self.logos.append(img)
                self.empresasMosaico.append(self.premium2[x[1]])
                
                x[1] += 1
            default:
                break
            }
        }
    }
    
    func getEmpresa(id: String) -> Empresa {
        for e in self.empresasMosaico {
            if e.id == id {
                return e
            }
        }
        let em = Empresa()
        return em
    }
    
    func addBtnSearch(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        btnSearch = UIImageView(image: UIImage(named: "btn_buscar"))
        btnSearch.userInteractionEnabled = true
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickSearch(_:)))
        btnSearch.addGestureRecognizer(tap)
        tap.delegate = self
        
        btnSearch.frame = CGRectMake(x, y, width, height)
        
        self.view.addSubview(btnSearch)
    }
    
    func clickSearch(gr: UIGestureRecognizer) {
        self.performSegueWithIdentifier("menuPesquisa", sender: self)
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
        
        self.view.addSubview(logo)
        self.view.addSubview(text)
    }
    
    func clickDetalhe(gr: UIGestureRecognizer) {
        self.performSegueWithIdentifier("detalhesCidade", sender: self)
    }
    
    func addLogo(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, p: Int, tag: String) {
        let logo = UIImageView()
        logo.tag = Int(tag)!
        logo.userInteractionEnabled = true
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickLogo(_:)))
        logo.addGestureRecognizer(tap)
        tap.delegate = self
        
        logo.af_setImageWithURL(NSURL(string: self.logos[p])!)
        logo.frame = CGRectMake(x, y, width, height)
        self.mosaico.addSubview(logo)
    }
    
    func clickLogo(gr: UIGestureRecognizer) {
        var id = String(gr.view?.tag)
        id = id.substringFromIndex(id.characters.indexOf("(")!.successor())
        id = id.substringToIndex(id.characters.indexOf(")")!)
        self.empresa = getEmpresa(id)
        self.performSegueWithIdentifier("menuDetalhesPremium", sender: self)
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
}

