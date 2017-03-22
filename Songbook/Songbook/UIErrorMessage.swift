
import Foundation

import UIKit

// A pop up button to display an error.
// Borrowed from my Senior Project - I wrote this class.
class UIErrorMessage
{
    //TODO make these non-optional
    var _viewController : UIViewController? = nil
    var _errorMessage : String? = nil
    public init(viewController: UIViewController, errorMessage: String)
    {
        _viewController = viewController
        _errorMessage = errorMessage
    }
    
    public func show()
    {
        let alert = UIAlertController(title: "Error", message: _errorMessage!, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        _viewController!.present(alert, animated: true, completion: nil)
    }
}
