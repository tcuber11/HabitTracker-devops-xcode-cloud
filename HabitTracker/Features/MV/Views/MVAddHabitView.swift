import SwiftUI

/// MV Architecture — form to create a new habit.
///
/// Local @State drives the form fields.
/// On submit, the store's createHabit action is called.
/// The store owns the mutation — the view owns only transient form state.
struct MVAddHabitView: View {
    @Environment(HabitStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var frequency: HabitFrequency = .daily
    @State private var selectedDays: Set<Weekday> = []
    @State private var isWeekly = false

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                frequencySection
            }
            .navigationTitle("New Habit")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: addHabit)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var nameSection: some View {
        Section("Habit") {
            TextField("Name", text: $name)
            TextField("Description (optional)", text: $description, axis: .vertical)
                .lineLimit(3...)
        }
    }

    private var frequencySection: some View {
        Section("Frequency") {
            Toggle("Weekly (specific days)", isOn: $isWeekly)
                .onChange(of: isWeekly) { _, newValue in
                    frequency = newValue ? .weekly(days: selectedDays) : .daily
                }
            if isWeekly {
                MVWeekdaySelectorView(selectedDays: $selectedDays)
                    .onChange(of: selectedDays) { _, newDays in
                        frequency = .weekly(days: newDays)
                    }
            }
        }
    }

    private func addHabit() {
        Task {
            await store.createHabit(name: name, description: description, frequency: frequency)
            dismiss()
        }
    }

    private func cancel() {
        dismiss()
    }
}

/// Weekday selection grid.
struct MVWeekdaySelectorView: View {
    @Binding var selectedDays: Set<Weekday>

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(Weekday.allCases) { day in
                MVWeekdayCell(day: day, isSelected: selectedDays.contains(day))
                    .onTapGesture {
                        toggleDay(day)
                    }
            }
        }
    }

    private func toggleDay(_ day: Weekday) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}

struct MVWeekdayCell: View {
    let day: Weekday
    let isSelected: Bool

    var body: some View {
        Text(day.shortName.prefix(1))
            .font(.caption.bold())
            .frame(width: 32, height: 32)
            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.15))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Circle())
    }
}
