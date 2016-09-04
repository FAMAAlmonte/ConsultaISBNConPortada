//
//  ViewController.swift
//  ConsultaOpenLibraryISBNConPortada
//
//  Created by Mauro Alberto Flores Almonte on 03/09/16.
//  Copyright © 2016 Mauro Alberto Flores Almonte. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var isbnTextField : UITextField!
    @IBOutlet weak var autores : UILabel!
    @IBOutlet weak var titulo : UILabel!
    @IBOutlet weak var portada : UIImageView!
    
    let url = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        asigVariables()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    func asigVariables () {
        
    
        autores.text = "Autor"
        titulo.text = "Título"
        portada.image = nil
    }
    
    func datosJson (isbnCode: String, completionHandler: (data: NSData?) -> Void) {
        
        if !isbnCode.isEmpty {
            
            NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url + isbnCode)!, completionHandler: {(data, response, error) in
                
                if error != nil {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.presentViewController(self.alerta("Error", mensaje: error!.localizedDescription), animated: true, completion: nil)
                    })
                    
                    return
                }
                
                completionHandler(data: data)
                
            }).resume()
            
        } else {
            
        }
    }
    
    func procesarJSON (isbn: String, data: NSData) {
        
        do {
            
            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String : AnyObject] {
                
                if let isbnJSON = json["ISBN:" + isbn] as? [String : AnyObject] {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self.autores.text = String()
                        
                        if let autores = isbnJSON["authors"] as? [AnyObject] {
                            
                            var prefix = ""
                            
                            for autor in autores {
                                
                                self.autores.text = self.autores.text! + prefix + (autor["name"] as! String)
                                prefix = ", "
                            }
                            
                        } else {
                            
                            self.autores.text = "Autor no definido"
                        }
                        
                        if let tituloIsbn = isbnJSON["title"] as? String {
                            
                            self.titulo.text = tituloIsbn
                            
                        } else {
                            
                            self.titulo.text = "Título no definido"
                        }
                        
                        if let isbnPortada = isbnJSON["cover"]?["medium"] as? String,
                            let imagen = UIImage(data: NSData(contentsOfURL: NSURL(string: isbnPortada)!)!) {
                            
                            self.portada.image = self.tamañoImagen(imagen, size: self.portada.frame.size)
                        }
                    })
                }
            }
            
        } catch {
            
            print("¡Error!")
        }
        
    }
    
    func tamañoImagen (imagen: UIImage, size: CGSize) -> UIImage? {
        
        var imageContext : UIImage?
        
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(0.0))
        imagen.drawInRect(CGRect(origin: CGPointZero, size: size))
        imageContext = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return imageContext
    }
    
    func alerta (titulo: String, mensaje: String) -> UIAlertController {
        
        let alerta = UIAlertController(title: titulo, message: mensaje, preferredStyle: .Alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        return alerta
    }
    
    
    @IBAction func buscarISBN (sender: UITextField) {
        
        asigVariables()
        
        datosJson(isbnTextField.text!) { data in
            
            self.procesarJSON(self.isbnTextField.text!, data: data!)
        }
    }
}