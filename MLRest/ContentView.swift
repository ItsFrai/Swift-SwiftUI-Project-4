//
//  ContentView.swift
//  MLRest
//
//  Created by Fraidoon Pourooshasb on 6/17/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeup = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = " "
    @State private var alertMessage = " "
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
            NavigationView {
                ZStack {
                    LinearGradient(colors: [.blue,.red], startPoint: .bottom, endPoint: .top).ignoresSafeArea()
                VStack {
                    Text("When do you want to wake up?").font(.headline)
                    DatePicker("Please enter a time", selection: $wakeup,displayedComponents: .hourAndMinute).labelsHidden()
                    
                    Text("Desired amount of sleep").font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25).frame(width: 250, height: 50)
                    
                    Text("Daily coffee intake").font(.headline)
                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...10).frame(width:250, height: 50)
                }
                .font(Font.system(size: 22))
                .navigationTitle("ML REST")
                .toolbar {
                    Button("Calculate", action: calculateBedtime).foregroundColor(.black).bold()
                }
                .alert(isPresented: $showingAlert) {
                                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    func calculateBedtime() {
        do {
            let model = try RestModel(configuration: MLModelConfiguration())
            
            let components = Calendar.current.dateComponents([.hour,.minute], from: wakeup)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeup - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
