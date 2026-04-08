import SwiftUI

struct LogMealFormView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss

    @State private var mealName = ""
    @State private var calories = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal Info") {
                    TextField("Meal name", text: $mealName)
                    TextField("Calories", text: $calories)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Log Meal")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveMeal()
                    }
                    .disabled(mealName.isEmpty || calories.isEmpty)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func saveMeal() {
        guard let cal = Int(calories) else { return }

        let entry = MealEntry(name: mealName, calories: cal)
        appState.logMeal(entry)

        dismiss()
    }
}

