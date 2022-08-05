//
//  CommandPaletteView.swift
//  CodeEdit
//
//  Created by Alex on 24.05.2022.
//

import SwiftUI
import Keybindings
import CodeEditUI

public struct CommandPaletteView: View {
    @ObservedObject private var state: CommandPaletteState
    @ObservedObject var commandManager: CommandManager = CommandManager.shared

    @State private var selectedItem: Command?
    private let closePalette: () -> Void

    public init(state: CommandPaletteState, closePalette: @escaping () -> Void) {
        self.state = state
        self.closePalette = closePalette
    }

    func resetState() {
        self.selectedItem = nil
        self.state.commandQuery = ""
    }

    func callHandler(command: Command) {
        closePalette()
        command.closureWrapper.call()
        resetState()
    }

    public var body: some View {
        VStack(spacing: 0.0) {
            VStack {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "command")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .padding(.leading, 20)
                        .offset(x: 0, y: 1)
                    TextField("Search Commands", text: $state.commandQuery)
                        .font(.system(size: 20, weight: .light, design: .default))
                        .textFieldStyle(.plain)
                        .onReceive(
                            state.$commandQuery
                                .debounce(for: .seconds(0.4), scheduler: DispatchQueue.main)
                        ) { val in
                            state.fetchMatchingCommands(val: val)
                        }
                    .padding(16)
                    .foregroundColor(Color(.systemGray).opacity(0.85))
                    .background(EffectView(.sidebar, blendingMode: .behindWindow))
                }
            }
            Divider()
            VStack(spacing: 0) {
                List(state.filteredCommands.isEmpty ?
                     commandManager.commands : state.filteredCommands, selection: $selectedItem) { command in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(command.title).foregroundColor(Color.white)
                                .padding(EdgeInsets.init(top: 0, leading: 10, bottom: 0, trailing: 0))
                                .frame(height: 10)
                        }.frame(maxWidth: .infinity, maxHeight: 15, alignment: .leading)
                            .listRowBackground(self.selectedItem == command ?
                                               RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color(.systemBlue)) :
                                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                .fill(Color.clear) )

                        .onTapGesture {
                            self.selectedItem = command
                            callHandler(command: command)
                        }.onHover(perform: { _ in self.selectedItem = command })
                    }.listStyle(SidebarListStyle())
                    
            }
        }
        .background(EffectView(.sidebar, blendingMode: .behindWindow))
        .foregroundColor(.gray)
        .edgesIgnoringSafeArea(.vertical)
        .frame(minWidth: 600,
           minHeight: self.state.isShowingCommandsList ? 400 : 28,
           maxHeight: self.state.isShowingCommandsList ? .infinity : 28)
    }
}

struct CommandPaletteView_Previews: PreviewProvider {
    static var previews: some View {
        CommandPaletteView(
            state: .init(),
            closePalette: {}
        )
    }
}
