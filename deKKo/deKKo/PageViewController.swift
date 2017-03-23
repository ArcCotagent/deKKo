//
//  PageViewController.swift
//  deKKo
//
//  Created by YangSzu Kai on 2017/3/21.
//  Copyright © 2017年 ArcCotagent. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource,UIPageViewControllerDelegate {

    //Make viewController in a viewcontorller array list
    lazy var VCArr: [UIViewController] = {
        
        return [self.VCInstance(name: "FirstVC"),
                self.VCInstance(name: "SecondVC")]
        
    }()
    
    //Instatiate each viewcontroller
    private func VCInstance(name: String)-> UIViewController {
        return UIStoryboard(name: "mainView", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        //Check if first vc exist or not
        if let firstVC = VCArr.first {
            //Set the firstVC as the first view controller
            self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Make the bottom dots transparent so that it won't have a black spacing
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //If it is scrollview make it bounds to the story frame
        //If it is pagecontrol then set no color
        for view in self.view.subviews{
            if view is UIScrollView{
                view.frame = UIScreen.main.bounds
            }else if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        //Checking if there are avialible viewController or not. If not return nil 
        //.index(current VC) get the current index
        guard let viewControllerIndex = VCArr.index(of: viewController) else{ return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        //Make sure it does not become negative
        guard previousIndex >= 0  else { return nil}
        
        //Check the total array VC should be greater than previous index
        guard VCArr.count > previousIndex else {return nil}
        
        //Return VC before the current view Controller
        return VCArr[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
       
        /*
         Precaution to make sure it does not crash
        */
        
        guard let viewControllerIndex = VCArr.index(of: viewController) else{ return nil }
        
        //Calculate next index
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex <= VCArr.count else { return nil }
        
        guard VCArr.count > nextIndex else { return nil }
        
        return VCArr[nextIndex]

    }
    
    /*
     Next Two functions are for the dots at the bottom of the view controller
    */
    
    //Number of UIViewController in total
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return VCArr.count
    }
    
    //This function tells what is the first VC dot
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
       
        //If the first VC exist, then the index is the first VC which is 0
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = VCArr.index(of: firstViewController) else {
            return 0
        }
        return firstViewControllerIndex
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

