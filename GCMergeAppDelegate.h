//
//  GCMergeAppDelegate.h
//  GCMerge
//
//  Created by Robert Carlsen on 21.11.2010.
//
//    Copyright (C) 2010, Robert Carlsen | robertcarlsen.net
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSXMLDocument.h>

@interface GCMergeAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;

    NSXMLDocument *xmlDocMaster;
    NSXMLDocument *xmlDocSlave;

    IBOutlet NSTextField     *masterLabel;
    IBOutlet NSTextField     *slaveLabel;

    IBOutlet NSButton        *mergeButton;

    IBOutlet NSSlider        *offsetSlider;
    IBOutlet NSTextField     *offsetLabel;

    IBOutlet double          manualOffsetSecs;
}

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic,retain) NSXMLDocument *xmlDocMaster;
@property (nonatomic,retain) NSXMLDocument *xmlDocSlave;
@property (nonatomic) IBOutlet double manualOffsetSecs;


- (IBAction)openXMLFile:(id)sender;
- (NSXMLDocument*)createXMLDocumentFromFile:(NSString *)file;

- (IBAction)mergeDocs:(id)sender;
//- (NSXMLDocument*)createMergedXML;
@end
