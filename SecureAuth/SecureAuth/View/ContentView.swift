//
//  ContentView.swift
//  SecureAuth
//
//  Created by Taooufiq El moutaoouakil on 3/16/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "lock.shield")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                        .scaleEffect(viewModel.isLoading ? 0.8 : 1.0)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.isLoading)
                    
                    Text("Secure Authentication")
                        .font(.system(size: 32, weight: .bold))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                        .padding(.horizontal)
                        .opacity(viewModel.isLoading ? 0.5 : 1.0)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.isLoading)
                    
                    Text("Enter your email address below. We'll verify your identity using biometrics before submitting.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                        .opacity(viewModel.isLoading ? 0.5 : 1.0)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.isLoading)
                    
                    Spacer().frame(height: 20)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("email@example.com", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(viewModel.isValidEmail ? Color.blue : Color.gray, lineWidth: 1)
                            )
                            .transition(.scale)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.isValidEmail)
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 30)
                    
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        viewModel.submitEmail()
                    }) {
                        HStack {
                            Text("Submit and Authenticate")
                                .fontWeight(.semibold)
                                .padding(.leading)
                            
                            Spacer()
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isValidEmail ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .disabled(!viewModel.isValidEmail || viewModel.isLoading)
                    .opacity(viewModel.isLoading ? 0.6 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                    
                    // Status messages with animations
                    if !viewModel.statusMessage.isEmpty {
                        HStack {
                            Image(systemName: viewModel.isError ? "exclamationmark.triangle" : "checkmark.circle")
                                .foregroundColor(viewModel.isError ? .red : .green)
                            
                            Text(viewModel.statusMessage)
                                .font(.callout)
                                .foregroundColor(viewModel.isError ? .red : .green)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.isError ? Color.red.opacity(0.1) : Color.green.opacity(0.1))
                        )
                        .padding(.horizontal)
                        .transition(.slide)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.statusMessage)
                    }
                    
                    Spacer()
                }
                .padding()
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

