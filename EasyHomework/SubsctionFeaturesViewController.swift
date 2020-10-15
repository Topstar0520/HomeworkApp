//
//  SubsctionFeaturesViewController.swift
//  B4Grad
//
//  Copyright © 2019 Anthony Giugno. All rights reserved.
//

import UIKit

struct SubscriptionFeature {
    var featureTitle: String?
    var featureDescription: String?
    var featureImage: String?
}

class SubscriptionFeaturePage: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descLabel: UILabel?
    @IBOutlet weak var imageView: UIImageView?
    
    var feature: SubscriptionFeature?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.titleLabel?.text = self.feature?.featureTitle
            self.descLabel?.text = self.feature?.featureDescription
            if let imageName = self.feature?.featureImage, let image = UIImage(named: imageName) {
                self.imageView?.image = image
            }
        }
    }
}

class SubsctionFeaturesViewController: UIPageViewController {

    var pageChangeCallback: ((Int)->())?
    private var pendingIndex: Int?

    lazy var features: Array<SubscriptionFeature> = {
        let feature1 = SubscriptionFeature(featureTitle: "Multi-Reminders", featureDescription: "Never stress about forgetting another quiz or assignment. Get notified 1 hour before or 1 week before - or both!", featureImage: "PlanFeature_1")
        let feature2 = SubscriptionFeature(featureTitle: "Timetable", featureDescription: "Instantly access your class schedule, and never miss another class whether it be a lecture, lab, or tutorial.", featureImage: "PlanFeature_2")
        let feature3 = SubscriptionFeature(featureTitle: "Subtasks", featureDescription: "Easily break that essay into small pieces, or track your studying for the next exam. Divide-and-Conquer.", featureImage: "PlanFeature_3")
        let feature4 = SubscriptionFeature(featureTitle: "Calendar", featureDescription: "Get a bird’s eye view of your tasks and observe your busiest times so you can plan ahead of them", featureImage: "PlanFeature_4")
        let feature5 = SubscriptionFeature(featureTitle: "Instructors", featureDescription: "Conveniently track teacher details such their email, website, office hours, even a picture!", featureImage: "PlanFeature_5")
        let feature6 = SubscriptionFeature(featureTitle: "Customize", featureDescription: "Get the Agenda you always wanted. Change the Color Palette of your courses, and select one of several beautiful backgrounds.", featureImage: "PlanFeature_6")
        let feature7 = SubscriptionFeature(featureTitle: "Quick Add", featureDescription: "Try the innovative Quick Add Button. Hold your finger down and quickly select the task type and course.", featureImage: "PlanFeature_7")
        return [feature1,feature2,feature3,feature4,feature5,feature6,feature7]
    }()
    
    lazy var subViewControllers:[UIViewController] = {
        var pages:[UIViewController] = []
        for (index,feature) in self.features.enumerated() {
            let page:SubscriptionFeaturePage  = UIStoryboard(name: "Subscription", bundle: nil).instantiateViewController(withIdentifier: "subscriptionFeaturePage") as! SubscriptionFeaturePage
            page.feature = feature
            pages.append(page)
        }
        return pages
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .lightGray
        return pageControl
    }()
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        setViewControllers([subViewControllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    private func pageUpdated(with index: Int) {
        if let callback = pageChangeCallback {
            callback(index)
        }
    }
}

extension SubsctionFeaturesViewController: UIPageViewControllerDelegate {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        if let first = pendingViewControllers.first {
            pendingIndex = subViewControllers.index(of: first)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let index = pendingIndex {
                self.pageUpdated(with: index)
            }
        }
    }
}

extension SubsctionFeaturesViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int = subViewControllers.index(of: viewController) ?? 0
        if(currentIndex <= 0) {
            return nil
        }
        return subViewControllers[currentIndex-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int = subViewControllers.index(of: viewController) ?? 0
        if(currentIndex >= subViewControllers.count-1) {
            return nil
        }
        return subViewControllers[currentIndex+1]
    }
}
