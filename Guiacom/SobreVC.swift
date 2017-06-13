//
//  SobreVC.swift
//  Guiacom
//
//  Created by José Cassimiro on 05/06/16.
//  Copyright © 2016 Guiacom Manhuaçu. All rights reserved.
//

import UIKit

class SobreVC: UIViewController, UIPopoverPresentationControllerDelegate {

    var receivedCitySigla: String = ""
    var receivedCity: String = ""
    var receivedId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func btBack(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
