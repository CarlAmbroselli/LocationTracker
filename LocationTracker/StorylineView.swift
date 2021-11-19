//
//  StorylineView.swift
//  LocationTracker
//
//  Created by Carl on 11.11.21.
//

import SwiftUI

struct StorylineView: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.managedObjectContext) private var viewContext
    
    @SectionedFetchRequest<String, Location>(
        sectionIdentifier: \.date!,
        sortDescriptors: [SortDescriptor(\.timestamp, order: .reverse)])
    private var locations: SectionedFetchResults<String,Location>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(locations) { entry in
                    NavigationLink {
                        ContentView(locations: entry)
                    } label: {
                        Text(entry.id)
                    }
                }
            }
            .navigationTitle("Location History")
            .toolbar {
                NavigationLink {
                    DropboxView(viewModel: viewModel.dropboxViewModel)
                } label: {
                    Text("Sync")
                }
            }
        }
    }
}

struct StorylineView_Previews: PreviewProvider {
    static var previews: some View {
        StorylineView(viewModel: ViewModel())
    }
}
