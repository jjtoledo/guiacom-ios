//
//  ContatoVC.swift
//  Guiacom
//
//  Created by José Cassimiro on 16/06/16.
//  Copyright © 2016 Guiacom Manhuaçu. All rights reserved.
//

import UIKit

class ContatoVC: UIViewController, UIGestureRecognizerDelegate {

    var receivedCitySigla: String = ""
    var receivedCity: String = ""
    var receivedId: String = ""
    
    @IBOutlet weak var lbContato: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapEmail:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetalhesPremiumVC.clickEmail(_:)))
        lbContato.addGestureRecognizer(tapEmail)
        tapEmail.delegate = self
    }

    @IBAction func btBack(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }    
    
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
    
    func clickEmail(gr:UITapGestureRecognizer) {
        dialog()
    }
    
    func dialog() {
        let message: String = "Deseja enviar um email?"
        
        let alert = UIAlertController(title: "Atenção",
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "Não", style: .Cancel, handler: { (action: UIAlertAction!) in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Sim", style: .Default, handler: { (action: UIAlertAction!) in
            if let url = NSURL(string: "mailto://\(self.lbContato.text)") {
                UIApplication.sharedApplication().openURL(url)
            }
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}
