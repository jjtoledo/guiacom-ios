//
//  DetalhesCidadeVC.swift
//  Guiacom
//
//  Created by José Cassimiro on 03/01/17.
//  Copyright © 2017 Guiacom Manhuaçu. All rights reserved.
//

import Alamofire
import AlamofireImage
import SwiftSpinner
import ImageSlideshow
import UIKit

class DetalhesCidadeVC: UIViewController {
    var slideshowTransitioningDelegate: ZoomAnimatedTransitioningDelegate?
    
    var receivedCitySigla: String = ""
    var receivedCity: String = ""
    var receivedId: String = ""
    
    var cidadeSigla: String = ""
    var cidade: String = ""
    var cidadeId: String = ""
    
    let width: CGFloat = UIScreen.mainScreen().bounds.width
    let height: CGFloat = UIScreen.mainScreen().bounds.height
    var larg2: CGFloat = 0.0
    
    @IBOutlet weak var lbCidade: UILabel!
    @IBOutlet weak var lbPref: UILabel!
    @IBOutlet weak var imgPref: UIImageView!
    @IBOutlet weak var txtDescricao: UITextView!    
    
    @IBAction func btCadastro(sender: AnyObject) {
        performSegueWithIdentifier("menuCadastro", sender: self)
    }
    
    @IBAction func btPesquisa(sender: AnyObject) {
        if receivedCitySigla == "" {
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
    
    @IBAction func btBack(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    let imgURL = "http://guiacomdigital.com.br/site/app/webroot/img/"
    let fotosURL = "http://guiacomdigital.com.br/webservice/getFotos.php"
    let detalhesURL = "http://guiacomdigital.com.br/webservice/getDetalhes.php"
    let checkPremiumURL = "http://guiacomdigital.com.br/webservice/checkCidadePossuiEmpresaPremium.php"
    
    var slideshow: ImageSlideshow!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        larg2 = (width/3)*2
        
        lbCidade.text = receivedCitySigla
        getFotos()
        getDetalhes()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .ScaleAspectFit
        
        let image = UIImage(named: "ic_logo_topo")
        imageView.image = image
        
        navigationItem.titleView = imageView
    }
    
    func getDetalhes() {
        SwiftSpinner.show("Carregando...")
        var json: JSON = ""
        Alamofire.request(.POST, detalhesURL, parameters: ["android": "android", "cidade_id": receivedId])
            .responseJSON { response in
                if let value = response.result.value {
                    json = JSON(value)
                    
                    let detalhe = Detalhe()
                    detalhe.foto_pref = json[0]["foto_pref"].stringValue
                    detalhe.descricao = json[0]["descricao"].stringValue
                    
                    if (detalhe.foto_pref != "") {
                        let img = NSURL(string: self.imgURL + detalhe.foto_pref)
                        self.imgPref.af_setImageWithURL(img!)
                    }
                    
                    self.txtDescricao.text = detalhe.descricao
                    SwiftSpinner.hide()
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
                    
                    if json.count != 0 {
                        var fotos = [Foto()]
                        var imgs = [InputSource]()
                        for i in 0...json.count-1 {
                            let foto = Foto()
                            foto.descricao = json[i]["descricao"].stringValue
                            foto.foto = self.imgURL + json[i]["foto"].stringValue
                            fotos.append(foto)
                            imgs.append(AlamofireSource(urlString: foto.foto)!)
                        }
                    
                        self.slideshow = ImageSlideshow()
                        self.slideshow.frame = CGRectMake(0, 125, self.width, self.height*0.225)
                        self.slideshow.setImageInputs(imgs)
                        self.view.addSubview(self.slideshow)
                    
                        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetalhesCidadeVC.click))
                        self.slideshow.addGestureRecognizer(tap)
                    }
                    SwiftSpinner.hide()
                }
        }
    }
    
    func click() {
        let ctr = FullScreenSlideshowViewController()
        // called when full-screen VC dismissed and used to set the page to our original slideshow
        ctr.pageSelected = { page in
            self.slideshow.setScrollViewPage(page, animated: false)
        }
        
        // set the initial page
        ctr.initialImageIndex = slideshow.scrollViewPage
        // set the inputs
        ctr.inputs = slideshow.images
        self.slideshowTransitioningDelegate = ZoomAnimatedTransitioningDelegate(slideshowView: slideshow, slideshowController: ctr)
        ctr.transitioningDelegate = self.slideshowTransitioningDelegate
        self.presentViewController(ctr, animated: true, completion: nil)
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
}