//
//  StartScreen.swift
//  OpenAIApp
//
//  Created by Hannah Bang on 4/9/23.
//

import SwiftUI
import OpenAIKit

struct StartScreen: View {
    @State private var selectedOption = 0
    let options = ["Generate Image", "Complete Sentence", "Analyze Sentiment"]

    let viewModel = ViewModel()

    var body: some View {
        NavigationView {
            VStack {
                //Picker
                Picker(selection: $selectedOption, label: Text("Select an option")) {
                    ForEach(0 ..< options.count) {
                        Text(self.options[$0])
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedOption == 0 {
                    GenerateImageView(viewModel: viewModel, selectedOption: $selectedOption)
                } else if selectedOption == 1 {
                    CompleteSentenceView(viewModel: viewModel)
                } else {
                    AnalyzeSentimentView(viewModel: viewModel)
                }
                
                Spacer()
            }
            .navigationTitle("OpenAI")
        }
    }

}

//Generate Image
struct GenerateImageView: View {
@ObservedObject var viewModel: ViewModel
@Binding var selectedOption: Int
@State var text = ""
@State var image: UIImage?

var body: some View{
    VStack{
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaledToFit()
                .frame(width: 150, height: 150)
        }
        else{
            Text("Type prompt to generate Image!")
        }
        Spacer()
        
        TextField("Type prompt here...", text: $text).padding()
        Button("Generate Image"){
            if !text.trimmingCharacters(in: .whitespaces).isEmpty{
                Task{
                    let result = await viewModel.generateImage(prompt: text)
                    if result == nil{
                        print("Failed to get Image")
                    }
                    self .image = result
                    selectedOption = 0 // Update the selectedOption variable in StartScreen
                }
            }
        }
            
    }
    .navigationTitle("DALL-E Image Generator")
    .onAppear{
        viewModel.setup()
    }
    .padding()
}
}

//Complete Sentence
struct CompleteSentenceView: View {
    @StateObject var viewModel = ViewModel()
    @State var prompt: String = ""
    @State var completion: String = ""
    @State var isLoading = false
    
    var body: some View {
        VStack {
            Text("Complete the sentence:")
                .font(.title)
                .padding()
            TextField("Enter an incomplete sentence...", text: $prompt)
                .padding()
            Button("Complete Sentence") {
                if !prompt.trimmingCharacters(in: .whitespaces).isEmpty {
                    Task {
                        isLoading = true
                        if let result = await viewModel.complete(prompt: prompt){
                            completion = result
                        }
                        isLoading = false
                    }
                }
            }.padding(.bottom)
            
            if isLoading {
                ProgressView()
            } else if !completion.isEmpty {
                Text("Completion:")
                    .font(.title)
                    .padding()
                Text(completion)
                    .padding()
            }
            Spacer()
        }
    }
}

//Analyze Sentiment
struct AnalyzeSentimentView: View {
    @StateObject var viewModel = ViewModel()
    @State var text = ""
    @State var sentiment: String?
    @State var isLoading = false
    
    var body: some View {
        VStack {
            Text("Enter a sentence to analyze sentiment:")
                .font(.title)
                .padding()
            TextField("Enter text...", text: $text)
                .padding()
            Button("Analyze Sentiment") {
                if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                    Task {
                        isLoading = true
                        sentiment = await viewModel.analyzeSentiment(prompt: text)
                        isLoading = false
                    }
                }
            }.padding(.bottom)
            
            if isLoading {
                ProgressView()
            } else if let sentiment = sentiment {
                Text("Sentiment Analysis Result:")
                    .font(.title)
                    .padding()
                Text(sentiment)
                    .padding()
            }
            Spacer()
        }
    }
}
                  
            
                 
struct StartScreen_Previews: PreviewProvider {
                     static var previews: some View {
                         StartScreen()
                     }
                 }
             
