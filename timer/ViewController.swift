//
//  ViewController.swift
//  timer
//
//  Created by 원동진 on 2022/09/19.
//

import UIKit
import AudioToolbox
enum TimerStatus {
    case start
    case pause
    case end
}
class ViewController: UIViewController {

    @IBOutlet weak var tomatoImageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var ProgressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var duration = 60
    var timerStatus : TimerStatus = .end
    var timer : DispatchSourceTimer?
    var currentSeconds = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        configureToggleButton()
        
    }
    func configureToggleButton(){
        self.startButton.setTitle("시작", for: .normal)
        self.startButton.setTitle("일시정지", for: .selected)
    }
    func setTimerInfoViewVisble(isHidden : Bool){
        self.timerLabel.isHidden = isHidden
        self.ProgressView.isHidden = isHidden
    }
    func startTimer(){
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1)
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return}
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600
                let min = (self.currentSeconds % 3600) / 60
                let second = ((self.currentSeconds % 3600) % 60)
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour,min,second)
                self.ProgressView.progress = Float(self.currentSeconds) / Float(self.duration)
                UIView.animate(withDuration: 0.5,delay: 0) {
                    self.tomatoImageView.transform = CGAffineTransform(rotationAngle: .pi)
                }//180
                UIView.animate(withDuration: 0.5,delay: 0.5) {
                    self.tomatoImageView.transform = CGAffineTransform(rotationAngle: .pi * 2 )
                }//+180
                //delay : N초뒤에 실행
                if self.currentSeconds <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                    //SystemSoundId : iphonedev.wiki 에서 확인가능
                }
                //핸들러,클로저,캡쳐 , self안에 ? , ?? 찾아보기
                //repeating ->1 초에 한번씩 핸들러 안에 있는 함수가 실행된다.
            })
            self.timer?.resume()
            //인터페이스 관련 스레드는 반드시 메인드스레드에서 작동되어야한다.
            //UI 관련 작업은 반드시 메인스레드에서 구현되어야 한다.
        }
    }
    func stopTimer(){
        if self.timerStatus == .pause {
            self.timer?.resume()
            //밑에 런타임에러로 인해 사용한구문
        }
        self.timerStatus  = .end
        self.cancelButton.isEnabled = false
        UIView.animate(withDuration: 0.5) {
            self.timerLabel.alpha = 0
            self.datePicker.alpha = 0
            self.datePicker.alpha = 1
            self.tomatoImageView.transform = .identity
            //.identity : 원상태로 복귀
        }
        self.startButton.isSelected = false
        self.timer?.cancel()
        self.timer = nil // 메모리에 해제 -> 안해주면 화면을 벗어나도 계속해서 동작한다.
        //일시정지 누른후 취소를 누르면 런타임에러 발생 -> 타이머를 suspend를 사용하여 일시정리를 하게되면 아직 수행할 작업이 있기에 nil 대입시 런타임에러 발생
    }
    @IBAction func tapCancelButton(_ sender: UIButton) {
        switch self.timerStatus {
        case  .start, .pause:
            stopTimer()
        default :
            break
            
        }
    }
    
    @IBAction func tapStartButton(_ sender: UIButton) {
        self.duration = Int(datePicker.countDownDuration)
        switch self.timerStatus {
        case .end:
            self.currentSeconds = self.duration
            self.timerStatus = .start
            UIView.animate(withDuration: 0.5) {
                self.timerLabel.alpha = 1
                self.datePicker.alpha = 1
                self.datePicker.alpha = 0
            }
            //withDuration 몇초동안 실행할건지
            //animations 현재값에서 최종값으로 변함
            self.startButton.isSelected = true
            self.cancelButton.isEnabled = true
            self.startTimer()
        case .start:
            self.timerStatus = .pause
            self.startButton.isSelected = false
            self.timer?.suspend()
        case .pause:
            self.timerStatus = .start
            self.startButton.isSelected = true
            self.timer?.resume()
        }
    }
}

