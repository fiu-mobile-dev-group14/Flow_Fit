import SwiftUI

struct NutritionView: View {
    @Environment(AppState.self) var appState
    @State private var isRefreshing = false
    @State private var showingLogMealForm = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: - Header
                    Text("Nutrition")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 8)
                    
                    // MARK: - Daily Summary
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Summary")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            SummaryCard(
                                title: "Calories",
                                value: "\(appState.totalCaloriesToday)",
                                unit: "kcal",
                                icon: "flame.fill",
                                color: .orange
                            )
                            SummaryCard(
                                title: "Meals",
                                value: "\(appState.todayMeals.count)",
                                unit: "logged",
                                icon: "fork.knife",
                                color: .green
                            )
                        }
                    }
                    
                    // MARK: - Today's Meals
                    if !appState.todayMeals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Today's Meals")
                                .font(.headline)
                            
                            ForEach(appState.todayMeals) { meal in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(meal.name)
                                        .font(.subheadline).bold()
                                    Text("\(meal.calories) kcal")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.regularMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    
                    // MARK: - Log Meal Button
                    Button {
                        showingLogMealForm = true
                    } label: {
                        Label("Log New Meal", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // MARK: - AI Meal Suggestions
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("AI Meal Suggestions")
                                .font(.headline)
                            Spacer()
                            Button {
                                Task {
                                    isRefreshing = true
                                    await RecommendationsService.shared.fetchSuggestions(for: appState)
                                    isRefreshing = false
                                }
                            } label: {
                                Label("Refresh", systemImage: "arrow.clockwise")
                            }
                            .font(.subheadline)
                        }
                        
                        if appState.isFetchingSuggestions || isRefreshing {
                            HStack {
                                ProgressView()
                                Text("Getting personalized suggestions…")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            
                        } else if appState.mealSuggestions.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .font(.title)
                                    .foregroundStyle(.purple)
                                Text("Tap Refresh to get AI-powered meal suggestions tailored to your goal.")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            
                        } else {
                            VStack(spacing: 10) {
                                ForEach(appState.mealSuggestions) { meal in
                                    SuggestionCard(
                                        title: meal.name,
                                        subtitle: "\(meal.estimatedCalories) kcal",
                                        detail: meal.description,
                                        color: .green
                                    )
                                    Button {
                                        let entry = MealEntry(
                                            name: meal.name,
                                            calories: meal.estimatedCalories,
                                            notes: "Added from AI suggestion",
                                            goal: appState.currentUser?.goal.rawValue ?? ""
                                        )
                                        appState.logMeal(entry)
                                    } label: {
                                        Label("Add to Today's Meals", systemImage: "plus.circle.fill")
                                            .font(.caption)
                                            .frame(maxWidth: .infinity)
                                            .padding(8)
                                            .background(Color.green.opacity(0.12))
                                            .foregroundColor(.green)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Food Ideas (Static)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Food Ideas")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• High‑protein snacks")
                            Text("• Low‑calorie meals")
                            Text("• Healthy breakfast options")
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("Nutrition")
            .navigationBarTitleDisplayMode(.large)
            .task {
                if appState.mealSuggestions.isEmpty {
                    await RecommendationsService.shared.fetchSuggestions(for: appState)
                }
            }
            .sheet(isPresented: $showingLogMealForm) {
                LogMealFormView()
                    .environment(appState)
            }
        }
    }
}

