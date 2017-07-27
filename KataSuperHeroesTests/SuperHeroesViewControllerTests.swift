//
//  SuperHeroesViewControllerTests.swift
//  KataSuperHeroes
//
//  Created by Pedro Vicente Gomez on 13/01/16.
//  Copyright © 2016 GoKarumi. All rights reserved.
//

import Foundation
import KIF
import Nimble
import UIKit
@testable import KataSuperHeroes

class SuperHeroesViewControllerTests: AcceptanceTestCase {

    fileprivate let repository = MockSuperHeroesRepository()

    func testShowsEmptyCaseIfThereAreNoSuperHeroes() {
        givenThereAreNoSuperHeroes()

        openSuperHeroesViewController()

        tester().waitForView(withAccessibilityLabel: "¯\\_(ツ)_/¯")
    }
    
    
    func testNotShowsEmptyCaseIfThereAreSuperHeroes () {
        givenThereAreSomeSuperHeroes(10)
        
        openSuperHeroesViewController()
        
        tester().waitForAbsenceOfView(withAccessibilityLabel: "¯\\_(ツ)_/¯")
    }
    
    func testShowsNotEmptyCaseIfThereAreSuperHeroes() {
        givenThereAreSomeSuperHeroes(10)
        
        openSuperHeroesViewController()
        
        let tableView = tester().waitForView(withAccessibilityLabel:"SuperHeroesTableView") as! UITableView
        
        expect(tableView.numberOfRows(inSection:0)).to(equal(10))
    }
    
    func testShowsThatWhenAreHeroesTheLoadingAreNotPresented () {
        givenThereAreSomeSuperHeroes(10)
        
        openSuperHeroesViewController()
        
        tester().waitForAbsenceOfView(withAccessibilityLabel: "LoadingView")
    }
    
    func testShowsThatTheHeroesInTheListHasTheCorrectName () {
        let superHeros = givenThereAreSomeSuperHeroes(10)
        
        openSuperHeroesViewController()
    
        for superHero in superHeros {
            tester().waitForView(withAccessibilityLabel: superHero.name)
        }
    }
    
    func testShowThatHeroesWillBeAvengers () {
        let superHeros = givenThereAreSomeSuperHeroes(10, avengers:true)
        
        openSuperHeroesViewController()
        
        for superHero in superHeros {
            tester().waitForView(withAccessibilityLabel: "\(superHero.name) - Avengers Badge")
        }
    }
    
    func testShowThatHeroesWillNotBeAvengers () {
        let superHeros = givenThereAreSomeSuperHeroes(10, avengers:false)
        
        openSuperHeroesViewController()
        
        for superHero in superHeros {
            tester().waitForAbsenceOfView(withAccessibilityLabel: "\(superHero.name) - Avengers Badge")
        }
    }
    
    func testShowThatHerosWillBeAvengersOnlyThePairs () {
        let superHeros = givenThereAreSomeSuperHeroes(10, avengers:true)
        
        openSuperHeroesViewController()
        
        var pairs: [SuperHero] = []
        for number in 0...superHeros.count-1 where number % 2 == 0 {
            pairs.append(superHeros[number])
        }
        
        for superHero in pairs {
            tester().waitForView(withAccessibilityLabel: "\(superHero.name) - Avengers Badge")
        }
    }
    
   func testShowThatHerosWillBeAvengersOnlyTheOdds () {
        let superHeros = givenThereAreSomeSuperHeroes(10, avengers:true)
        
        openSuperHeroesViewController()
    
        var odds: [SuperHero] = []
        for number in 0...superHeros.count-1 where number % 2 == 1 {
            odds.append(superHeros[number])
        }
        
        for superHero in odds {
            tester().waitForView(withAccessibilityLabel: "\(superHero.name) - Avengers Badge")
        }
    }

    func testShowTheNameOfSuperHeroTappedInTheList () {
        let superHeros = givenThereAreSomeSuperHeroes()
        
        openSuperHeroesViewController()
        
        let tableView = tester().waitForView(withAccessibilityLabel:"SuperHeroesTableView") as! UITableView
        
        let indexPath = IndexPath(item:0, section:0)
        
        tester().tapRow(at:indexPath, in:tableView)
        
        tester().waitForView(withAccessibilityLabel: superHeros[0].name)
        
    }
    
    fileprivate func givenThereAreNoSuperHeroes() {
        _ = givenThereAreSomeSuperHeroes(0)
    }

    fileprivate func givenThereAreSomeSuperHeroes(_ numberOfSuperHeroes: Int = 10,
        avengers: Bool = false) -> [SuperHero] {
        var superHeroes = [SuperHero]()
        for i in 0..<numberOfSuperHeroes {
            let superHero = SuperHero(name: "SuperHero - \(i)",
                photo: NSURL(string: "https://i.annihil.us/u/prod/marvel/i/mg/c/60/55b6a28ef24fa.jpg") as URL?,
                isAvenger: avengers, description: "Description - \(i)")
            superHeroes.append(superHero)
        }
        repository.superHeroes = superHeroes
        return superHeroes
    }

    fileprivate func openSuperHeroesViewController() {
        let superHeroesViewController = ServiceLocator()
            .provideSuperHeroesViewController() as! SuperHeroesViewController
        superHeroesViewController.presenter = SuperHeroesPresenter(ui: superHeroesViewController,
                getSuperHeroes: GetSuperHeroes(repository: repository))
        let rootViewController = UINavigationController()
        rootViewController.viewControllers = [superHeroesViewController]
        present(viewController: rootViewController)
        tester().waitForAnimationsToFinish()
    }
}
