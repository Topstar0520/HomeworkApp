import UIKit

class CarouselViewController: UIViewController {

    @IBOutlet weak var vwContainer: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var textLabel: UILabel!
    var presentingVC: HomeworkViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pageControl.currentPage = 0
        
        let button = self.view.viewWithTag(3) as! UIButton
        button.layer.cornerRadius = button.frame.size.width / 15
        button.addTarget(self, action: #selector(self.buttonClicked), for: .touchUpInside)
    }
    
    @objc func buttonClicked() {
        self.dismiss(animated: true) {
            let storyboard = UIStoryboard(name: "Subscription", bundle: nil)
            let subscriptionPlansVC = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlansViewController") as! SubscriptionPlansViewController
            subscriptionPlansVC.customHeadlineText = "Start Your Free Trial Now!"
            //Math Learner Style (search these keywords to find related code.)
            // Uncomment equivalent code in HomeworkViewController if you uncomment 5 lines below.
            //subscriptionPlansVC.customHeadlineText = "Your Free Trial Starts Now!" //uncomment if Free Trial Style.
            subscriptionPlansVC.customHeadlineText = "It's Time to Get Organized. Unlock Your New Agenda."
            //Math Learner Style
            subscriptionPlansVC.view.viewWithTag(101)?.isHidden = true
            if #available(iOS 13.0, *) {
                subscriptionPlansVC.isModalInPresentation = true
            }
             //
            self.presentingVC.present(subscriptionPlansVC, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: "AppLaunchedBefore")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Embedded") {
            let containerVC = segue.destination as! CarouselPageViewController
            containerVC.parentVC = self
        }
    }
}

