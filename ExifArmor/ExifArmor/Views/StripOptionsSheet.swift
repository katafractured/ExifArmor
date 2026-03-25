import SwiftUI

struct StripOptionsSheet: View {
    @Binding var options: StripOptions
    let onConfirm: () -> Void

    @Environment(StoreManager.self) private var store

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $options.removeAll) {
                        Label("Remove Everything", systemImage: "trash.fill")
                    }
                    .tint(Color("AccentCyan"))
                    .onChange(of: options.removeAll) { _, newValue in
                        if newValue {
                            options.removeLocation = true
                            options.removeDateTime = true
                            options.removeDeviceInfo = true
                            options.removeCameraSettings = true
                        }
                    }
                } footer: {
                    Text("Removes all metadata except image orientation.")
                }

                if !options.removeAll {
                    Section("Choose What to Remove") {
                        Toggle(isOn: $options.removeLocation) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text("GPS Location")
                                    Text("Coordinates, altitude")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: "location.fill")
                                    .foregroundStyle(Color("WarningRed"))
                            }
                        }
                        .tint(Color("AccentCyan"))

                        Toggle(isOn: $options.removeDateTime) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text("Date & Time")
                                    Text("When the photo was taken")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: "clock.fill")
                                    .foregroundStyle(Color("AccentGold"))
                            }
                        }
                        .tint(Color("AccentCyan"))

                        Toggle(isOn: $options.removeDeviceInfo) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text("Device Info")
                                    Text("Phone model, OS version")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: "iphone")
                                    .foregroundStyle(Color("AccentMagenta"))
                            }
                        }
                        .tint(Color("AccentCyan"))

                        Toggle(isOn: $options.removeCameraSettings) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text("Camera Settings")
                                    Text("Lens, aperture, ISO, shutter speed")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: "camera.fill")
                                    .foregroundStyle(Color("AccentCyan"))
                            }
                        }
                        .tint(Color("AccentCyan"))
                    }
                }

                if !store.isPro {
                    Section {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(Color("AccentMagenta"))
                            Text("Custom strip requires Pro")
                                .font(.subheadline)
                                .foregroundStyle(Color("TextSecondary"))
                        }
                    }
                }
            }
            .navigationTitle("Strip Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Strip", action: onConfirm)
                        .bold()
                        .disabled(!store.isPro && !options.removeAll)
                }
            }
        }
    }
}
