import Foundation
import UIKit
import AVFoundation

class CarouselPageViewController: UIPageViewController, UIPageViewControllerDelegate {
    
    var parentVC: CarouselViewController!
    fileprivate var items: [UIViewController] = []
    var titles = ["In Three Simple Steps, you will Organize Your Academic Life.", "First, Create Your Courses.", "Second, Add Your Assignments, Quizzes, Lectures, and other content.", "Third, Sit Back and Relax!"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        self.parentVC.textLabel.text = titles[0]
        
        decoratePageControl()
        
        populateItems()
        if let firstViewController = items.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    var firstAppear = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (firstAppear == true) {
            self.playAudio()
            firstAppear = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.timer?.invalidate()
    }
    
    fileprivate func decoratePageControl() {
        /*let pc = UIPageControl.appearance(whenContainedInInstancesOf: [CarouselPageViewController.self])
        pc.currentPageIndicatorTintColor = .green
        pc.pageIndicatorTintColor = .gray*/
        
        let pageControl = UIPageControl.appearance(whenContainedInInstancesOf: [CarouselViewController.self])
        pageControl.currentPageIndicatorTintColor = .green
        pageControl.pageIndicatorTintColor = .gray
        
    }
    
    fileprivate func populateItems() {
        var imageNames = ["iphone-1", "iphone-2", "iphone-3", "iphone-4"]
        if (DeviceType.IS_IPAD) {
            imageNames = ["ipad-1", "ipad-2", "ipad-3", "ipad-4"]
        }
        let backgroundColor:[UIColor] = [.clear, .clear, .clear, .clear]
        
        for (index, t) in imageNames.enumerated() {
            let c = createCarouselItemControler(with: t, with: backgroundColor[index])
            items.append(c)
        }
    }
    
    fileprivate func createCarouselItemControler(with imageName: String, with color: UIColor?) -> UIViewController {
        let c = UIViewController()
        c.view = CarouselItem(imageName: imageName, background: color)

        return c
    }
    
    // Audio

    var audioPlayer: AVAudioPlayer?

    func playAudio() {
        
        guard let url = Bundle.main.url(forResource: "B4Grad_Tara", withExtension: "mp3") else {
                print("error to get the mp3 file")
                return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch {
            print("audio file error")
        }
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateAudioPlayback), userInfo: nil, repeats: true)
        audioPlayer?.volume = 1.0
        audioPlayer?.play()
    }
    var timer: Timer?
    
    var pageReached = 0
    @objc func updateAudioPlayback() {
        if (self.audioPlayer == nil) {
            return
        }
        if (self.audioPlayer?.isPlaying == false) {
            let currentTime = audioPlayer!.currentTime
            if (currentTime == audioPlayer!.duration) {
                return
            }
            if (currentTime >= 3.7 && currentTime <= 5.7 && self.parentVC.pageControl.currentPage == 1) {
                self.audioPlayer!.play()
                pageReached = 1
            }
            
            if (currentTime >= 5.7 && currentTime <= 9.5 && self.parentVC.pageControl.currentPage == 2) {
                self.audioPlayer!.play()
                pageReached = 2
            }
            
            if (currentTime >= 9.5 && currentTime <= audioPlayer!.duration && self.parentVC.pageControl.currentPage == 3) {
                self.audioPlayer!.play()
                pageReached = 3
            }
        }
        if (self.audioPlayer?.isPlaying == true) {
           // Pause if page is not beyond certain point.
            let currentTime = audioPlayer!.currentTime
            if (currentTime >= 3.7 && pageReached == 0) {
                self.audioPlayer!.stop()
            }
            
            if (currentTime >= 5.7 && pageReached == 1) {
                self.audioPlayer!.stop()
            }
            
            if (currentTime >= 9.5 && pageReached == 2) {
                self.audioPlayer!.stop()
            }
            
            /*if (currentTime >= 3.7 && self.parentVC.pageControl.currentPage == 3) {
                self.audioPlayer!.stop()
            }*/
        }
    }
    
}

// MARK: - DataSource

extension CarouselPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var viewControllerIndex = items.index(of: viewController)
        
        if (viewControllerIndex == nil || viewControllerIndex == 0) || (viewControllerIndex == NSNotFound) {
            return nil
        }
        
        viewControllerIndex = viewControllerIndex! - 1
        
        return items[viewControllerIndex!]
    }
    
    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var viewControllerIndex = items.index(of: viewController)
        
        if (viewControllerIndex == nil || viewControllerIndex == NSNotFound) {
            return nil
        }
        
        viewControllerIndex = viewControllerIndex! + 1
        if (viewControllerIndex == items.count) {
            return nil
        }
        
        return items[viewControllerIndex!]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (completed == true) {
            if let firstViewController = viewControllers?.first {
                let viewControllerIndex = items.index(of: firstViewController)
                self.parentVC.pageControl.currentPage = viewControllerIndex!
                self.parentVC.textLabel.text = titles[viewControllerIndex!]
            }
        }
        
        /*if let firstViewController = viewControllers?.first,
            let index = orderedViewControllers.indexOf(firstViewController) {
            tutorialDelegate?.tutorialPageViewController(self,
                                                         didUpdatePageIndex: index)
        }*/
    }
    
    func presentationCount(for _: UIPageViewController) -> Int {
        return items.count
    }
    
    func presentationIndex(for _: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = items.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
}
