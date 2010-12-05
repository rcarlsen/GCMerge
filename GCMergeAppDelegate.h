//
//  GCMergeAppDelegate.h
//  GCMerge
//
//  Created by Robert Carlsen on 21.11.2010.
//  Copyright 2010 robertcarlsen.net. All rights reserved.
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
