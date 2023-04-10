//
//  ContentView.swift
//  OpenAIApp
//
//  Created by Hannah Bang on 4/9/23.
//
//
//  ContentView.swift
//  OpenAIApp
//
//  Created by Hannah Bang on 4/9/23.
//

import SwiftUI
import OpenAIKit

//ViewModel class, all 3 functions
final class ViewModel: ObservableObject{
    private var openai: OpenAI?
    
    func setup() {
        
        openai = OpenAI(Configuration(organizationId: "Personal", apiKey: "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"))
    }
    func generateImage(prompt: String) async -> UIImage? {
        guard let openai = openai else {
            return nil
        }
        
        do {
            let params = ImageParameters(prompt: prompt, resolution: .medium, responseFormat: .base64Json)
            let result = try await openai.createImage(parameters: params)
            let data = result.data[0].image
            let image = try openai.decodeBase64Image(data)
            return image
        }
        
        catch {
            print(String(describing: error))
            return nil
        }
    }
    
    func complete(prompt: String) async -> String? {
        
        guard let openai = openai else {
            return nil
        }
        do {
            let completionParameter = CompletionParameters(
                model: "text-davinci-002",
                prompt: [prompt],
                maxTokens: 50,
                temperature: 0.98,
                presencePenalty: 0.0,
                frequencyPenalty: 0.5
            )
            let completionResponse = try await openai.generateCompletion(
                parameters: completionParameter
            )
            guard let responseText = completionResponse.choices.first?.text else{
                return nil
            }
            return responseText
        } catch{
            print(String(describing: error))
            return nil
        }//end of catch
    }//end of func complete
    
    func analyzeSentiment(prompt: String) async -> String{
        guard let openai = openai else {
            return ""
        }
        do {
            let parameters = CompletionParameters(model: "text-davinci-003", prompt: ["Decide whether a Tweet's sentiment is positive, neutral, or negative. \n\nTweet: \"\(prompt)\""], maxTokens: 60, temperature: 0, topP: 1.0, presencePenalty: 0.0, frequencyPenalty: 0.5)
            let response = try await openai.generateCompletion(parameters: parameters)
            return String(response.choices.first?.text ?? "No response")
            
        } catch {
            print(error)
        }
        return ""
    }
}

//Image Generation code
struct ContentView: View {
@ObservedObject var viewModel = ViewModel()
    @State var text = ""
    @State var image: UIImage?
    
    var body: some View{
        NavigationView {
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
   
    

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
