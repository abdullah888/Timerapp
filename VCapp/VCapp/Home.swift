//
//  Home.swift
//  VCapp
//
//  Created by abdullah on 14/01/1444 AH.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var TimeModel: TimeViewModel
    var body: some View {
        VStack{
            Text("منبه")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            
            GeometryReader{proxy in
                VStack(spacing: 15){
                    ZStack{
                        Circle()
                            .fill(.white.opacity(0.03))
                            .padding(-40)
                        
                        Circle()
                            .trim(from: 0, to: TimeModel.progress)
                            .stroke(.white.opacity(0.03),lineWidth: 80)
                        
                        Circle()
                            .stroke(.red,lineWidth: 5)
                            .blur(radius: 15)
                            .padding(-2)
                        
                        Circle()
                            .fill(.black)
                        
                        Circle()
                            .trim(from: 0, to: TimeModel.progress)
                            .stroke(.red.opacity(0.7),lineWidth: 10)
                        
                        GeometryReader{proxy in
                            let size = proxy.size
                            
                            Circle()
                                .fill(.red)
                                .frame(width: 30, height: 30)
                                .overlay(content: {
                                    Circle()
                                        .fill(.white)
                                        .padding(5)
                                })
                                .frame(width: size.width, height: size.height, alignment: .center)
                           
                                .offset(x: size.height / 2)
                                .rotationEffect(.init(degrees: TimeModel.progress * 360))
                        }
                        
                        Text(TimeModel.timerStringValue)
                            .font(.system(size: 45, weight: .light))
                            .rotationEffect(.init(degrees: 90))
                            .animation(.none, value: TimeModel.progress)
                    }
                    .padding(60)
                    .frame(height: proxy.size.width)
                    .rotationEffect(.init(degrees: -90))
                    .animation(.easeInOut, value: TimeModel.progress)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    
                    Button {
                        if TimeModel.isStarted{
                            TimeModel.stopTimer()
                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        }else{
                            TimeModel.addNewTimer = true
                        }
                    } label: {
                        Image(systemName: !TimeModel.isStarted ? "alarm.fill" : "stop.fill")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background{
                                Circle()
                                    .fill(.red)
                            }
                            .shadow(color: .red, radius: 8, x: 0, y: 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .padding()
        .background{
            Color(.black)
                .ignoresSafeArea()
        }
        .overlay(content: {
            ZStack{
                Color.black
                    .opacity(TimeModel.addNewTimer ? 0.25 : 0)
                    .onTapGesture {
                        TimeModel.hour = 0
                        TimeModel.minutes = 0
                        TimeModel.seconds = 0
                        TimeModel.addNewTimer = false
                    }
                
                NewTimerView()
                    .frame(maxHeight: .infinity,alignment: .bottom)
                    .offset(y: TimeModel.addNewTimer ? 0 : 400)
            }
            .animation(.easeInOut, value: TimeModel.addNewTimer)
        })
        .preferredColorScheme(.dark)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            if TimeModel.isStarted{
                TimeModel.updateTimer()
            }
        }
        .alert("الوقت المحدد انتهى", isPresented: $TimeModel.isFinished) {
            Button("انشاء جديد",role: .cancel){
                TimeModel.stopTimer()
                TimeModel.addNewTimer = true
            }
            Button("خروج",role: .destructive){
                TimeModel.stopTimer()
            }
        }
    }
    
    // MARK: New Timer Bottom Sheet
    @ViewBuilder
    func NewTimerView()->some View{
        VStack(spacing: 15){
            Text("انشاء تنبيه")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.top,10)
            
            HStack(spacing: 15){
                Text("\(TimeModel.hour) الساعة")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 12, hint: "الساعة") { value in
                            TimeModel.hour = value
                        }
                    }
                
                Text("\(TimeModel.minutes) الدقيقة")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 60, hint: "الدقيقة") { value in
                            TimeModel.minutes = value
                        }
                    }
                
                Text("\(TimeModel.seconds) الثانية")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,12)
                    .background{
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu{
                        ContextMenuOptions(maxValue: 60, hint: "الثانية") { value in
                            TimeModel.seconds = value
                        }
                    }
            }
            .padding(.top,20)
            
            Button {
                TimeModel.startTimer()
            } label: {
                Text("حفظ")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .padding(.horizontal,100)
                    .background{
                        Capsule()
                            .fill(.red)
                    }
            }
            .disabled(TimeModel.seconds == 0)
            .opacity(TimeModel.seconds == 0 ? 0.5 : 1)
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.black))
                .ignoresSafeArea()
        }
    }
    
    // MARK: Reusable Context Menu Options
    @ViewBuilder
    func ContextMenuOptions(maxValue: Int,hint: String,onClick: @escaping (Int)->())->some View{
        ForEach(0...maxValue,id: \.self){value in
            Button("\(value) \(hint)"){
                onClick(value)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TimeViewModel())
    }
}
