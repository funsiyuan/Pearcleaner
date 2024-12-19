//
//  AppListH.swift
//  Pearcleaner
//
//  Created by Alin Lupascu on 11/5/23.
//

import Foundation
import SwiftUI
import AlinFoundation

struct RegularMode: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var locations: Locations
    @EnvironmentObject var fsm: FolderSettingsManager
    @AppStorage("settings.general.glass") private var glass: Bool = false
    @AppStorage("settings.general.sidebarWidth") private var sidebarWidth: Double = 280
    @AppStorage("settings.menubar.enabled") private var menubarEnabled: Bool = false
    @AppStorage("settings.general.mini") private var mini: Bool = false
    @AppStorage("settings.interface.animationEnabled") private var animationEnabled: Bool = true
    @Binding var search: String
    @State private var showSys: Bool = true
    @State private var showUsr: Bool = true
    @Binding var showPopover: Bool
    @State private var showMenu = false
    @State var isMenuBar: Bool = false
    @State private var isExpanded: Bool = false

    var body: some View {

        // Main App Window
        ZStack() {

            if appState.currentPage == .applications {
                HStack(alignment: .center, spacing: 0) {

                    // App List
                    AppSearchView(glass: glass, menubarEnabled: menubarEnabled, mini: mini, search: $search, showPopover: $showPopover, isMenuBar: $isMenuBar)
                        .frame(width: sidebarWidth)
                        .transition(.opacity)

                    SlideableDivider(dimension: $sidebarWidth)
                        .zIndex(3)


                    // Details View
                    HStack(spacing: 0) {
                        Spacer()
                        Group {
                            if appState.currentView == .empty || appState.currentView == .apps {
                                AppDetailsEmptyView()
                            } else if appState.currentView == .files {
                                FilesView(showPopover: $showPopover, search: $search)
                                    .id(appState.appInfo.id)
                            } else if appState.currentView == .zombie {
                                ZombieView(showPopover: $showPopover, search: $search)
                                    .id(appState.appInfo.id)
                            }
                        }
                        .transition(.opacity)
                        Spacer()
                    }
                    .zIndex(2)
                }

            } else if appState.currentPage == .orphans {
                ZombieView(showPopover: $showPopover, search: $search)
                    .onAppear {
                        if appState.zombieFile.fileSize.keys.isEmpty {
                            appState.showProgress.toggle()
                        }
                        withAnimation(Animation.easeInOut(duration: animationEnabled ? 0.35 : 0)) {
                            if appState.zombieFile.fileSize.keys.isEmpty {
                                reversePreloader(allApps: appState.sortedApps, appState: appState, locations: locations, fsm: fsm)
                            }
                        }
                    }
            } else if appState.currentPage == .development {
                EnvironmentCleanerView()
            }



            VStack(spacing: 0) {

                HStack {
                    Spacer()
#if DEBUG
                    Text(verbatim: "DEBUG").foregroundStyle(.orange).bold()
                        .help(Text(verbatim: "VERSION: \(Bundle.main.version) | BUILD: \(Bundle.main.buildVersion)"))
#endif
                    CustomPickerButton(
                        selectedOption: $appState.currentPage,
                        isExpanded: $isExpanded,
                        options: CurrentPage.allCases.sorted { $0.title < $1.title } // Sort by title
                    )
                    .padding(6)
//                    .padding(.vertical, 2)

                }


                Spacer()
            }

        }
        .background(backgroundView(themeManager: themeManager))
        .frame(minWidth: appState.currentPage == .orphans ? 700 : 900, minHeight: 600)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            withAnimation(Animation.spring(duration: animationEnabled ? 0.35 : 0)) {
                if isExpanded {
                    isExpanded = false
                }
            }

        }


    }
}






struct AppDetailsEmptyView: View {

    var body: some View {
        VStack(alignment: .center) {

            Spacer()

            PearDropView()

//            GlowGradientButton()

            Spacer()

        }

    }
}
