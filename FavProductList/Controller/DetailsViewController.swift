import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var priceTextfield: UITextField!
    @IBOutlet weak var brandTextfield: UITextField!
    @IBOutlet weak var sizeTextfield: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectProductName = ""
    var selectProductUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectProductName != "" {
            saveButton.isHidden = true
            if let uuidString = selectProductUUID?.uuidString{
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shop")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0{
                        for sonuc in sonuclar as! [NSManagedObject] {
                            if let name = sonuc.value(forKey: "name") as? String{
                                nameTextfield.text = name
                            }
                            if let price = sonuc.value(forKey: "price") as? Int{
                                priceTextfield.text = String(price)
                            }
                            if let brand = sonuc.value(forKey: "brand") as? String{
                                brandTextfield.text = brand
                            }
                            if let size = sonuc.value(forKey: "size") as? String{
                                sizeTextfield.text = size
                            }
                            if let imageData = sonuc.value(forKey: "image") as? Data{
                                let image = UIImage(data: imageData)
                                imageView.image = image
                            }
                        }
                    }
                          
                } catch {
                    print("Hata")
                }
            }
        } else {
            nameTextfield.text = ""
            priceTextfield.text = ""
            brandTextfield.text = ""
            sizeTextfield.text = ""
            saveButton.isHidden = false
        }
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    @objc func chooseImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }

    @IBAction func saveProduct(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let shop = NSEntityDescription.insertNewObject(forEntityName: "Shop", into: context)
        
        shop.setValue(nameTextfield.text!, forKey: "name")
        shop.setValue(brandTextfield.text!, forKey: "brand")
        shop.setValue(sizeTextfield.text!, forKey: "size")
        if let price = Int(priceTextfield.text!){
            shop.setValue(price, forKey: "price")
        }
        shop.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        shop.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("Kayıt edildi")
        } catch {
            print("HATA")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addedNewProduct"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
