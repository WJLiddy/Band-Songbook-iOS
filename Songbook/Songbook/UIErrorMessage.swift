
import Foundation

import UIKit

// A pop up button to display an error.
// Borrowed from my Senior Project - but I wrote this class.
class UIErrorMessage
{
    let _viewController : UIViewController
    let _errorMessage : String
    public init(viewController: UIViewController, errorMessage: String)
    {
        _viewController = viewController
        _errorMessage = errorMessage
    }
    
    // show message that can be dismissed by pressing ok
    public func show()
    {
        let alert = UIAlertController(title: "Error", message: _errorMessage, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        _viewController.present(alert, animated: true, completion: nil)
    }
}
