//
//  GCMergeAppDelegate.m
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

#import "GCMergeAppDelegate.h"

#define kMasterButtonTag 33
#define kSlaveButtonTag  66

@implementation NSXMLElement (Private)
- (id)valueForUndefinedKey:(NSString *)key
{
	return [self attributeForName:key];
}
@end


@interface GCMergeAppDelegate (private)
- (void) calculateTimeOffset;
@end



@implementation GCMergeAppDelegate

@synthesize window;
@synthesize xmlDocSlave, xmlDocMaster;
@synthesize manualOffsetSecs;

- (void)dealloc
{
    [xmlDocMaster release];
    [xmlDocSlave release];

    [super dealloc];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}


// this is just testing:
- (IBAction)openXMLFile:(id)sender
{
    int result;
    NSArray *filetypes = [NSArray arrayWithObjects:@"xml",@"gc",nil];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];

    [oPanel setAllowsMultipleSelection:NO];

    result = [oPanel runModalForDirectory:nil file:nil types:filetypes];
    if ( result == NSOKButton) {
        NSString *aFile = [oPanel filename];

        // pass a specific doc depending on the button pressed:
        if([(NSButton*)sender tag] == kMasterButtonTag ) {
            xmlDocMaster = [[self createXMLDocumentFromFile:aFile] retain];
            [masterLabel setTitleWithMnemonic:[aFile lastPathComponent]];
        }
        else if([(NSButton*)sender tag] == kSlaveButtonTag) {
            xmlDocSlave = [[self createXMLDocumentFromFile:aFile] retain];
            [slaveLabel setTitleWithMnemonic:[aFile lastPathComponent]];
        }
        //[sourceTextView setString:[NSString stringWithFormat:@"%@", xmlDoc]];

        if (xmlDocMaster && xmlDocSlave) {
            [self calculateTimeOffset];

            [mergeButton setEnabled:YES];

            [offsetSlider setEnabled:YES];
            [offsetSlider setRefusesFirstResponder:NO];
            [offsetLabel setEnabled:YES];
            [offsetLabel setEditable:YES];
        }
        else {
            [mergeButton setEnabled:NO];

            [offsetSlider setEnabled:NO];
            [offsetSlider setRefusesFirstResponder:YES];
            [offsetLabel setEnabled:NO];
            [offsetLabel setEditable:NO];
        }
    }

}


- (NSXMLDocument*)createXMLDocumentFromFile:(NSString *)file
{
    NSError *err = nil;

    NSURL *furl = [NSURL fileURLWithPath:file];
    if( !furl )
    {
        NSLog(@"Can't create an URL from file %@.", file );
        return nil;
    }

    NSXMLDocument *xmlDoc;

    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&err];
    if( xmlDoc == nil )
    {
        // in previous attempt, it failed creating XMLDocument because it
        // was malformed.
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl options:NSXMLDocumentTidyXML error:&err];
    }
    if( xmlDoc == nil)
    {

        NSLog( @"Error occurred while creating an XML document.");
        //        if(err)
        //            [self handleError:err];
    }
    else
    {
        // we've got the doc...
        // NSLog(@"%@", xmlDoc);
        return [xmlDoc autorelease];
    }

    return nil;
}


- (void) calculateTimeOffset;
{
    // look at the "Start time" attribute to help align data
    NSDateFormatter *gcDateFormatter = [[NSDateFormatter alloc] initWithDateFormat:@"yyyy/MM/dd HH:mm:ss zzz"
                                                              allowNaturalLanguage:YES];

    NSString *timePath = @"//attribute[@key='Start time']";

    NSArray *masterAttributes = [xmlDocMaster nodesForXPath:timePath error:nil];
    NSArray *slaveAttributes = [xmlDocSlave nodesForXPath:timePath error:nil];

    NSString *masterStartString = [[[masterAttributes objectAtIndex:0]
                                    attributeForName:@"value"] stringValue];
    NSString *slaveStartString = [[[slaveAttributes objectAtIndex:0]
                                   attributeForName:@"value"] stringValue];

    NSDate *masterDate = [gcDateFormatter dateFromString:masterStartString];
    NSDate *slaveDate = [gcDateFormatter dateFromString:slaveStartString];

    // this is the time offset between the two files:
    self.manualOffsetSecs = [masterDate timeIntervalSinceDate:slaveDate];
    NSLog(@"offset time: %d", self.manualOffsetSecs);

    [gcDateFormatter release];
    //---//
}

// TODO: analyze data to attempt to "fit" them and derive the offset
// TODO: enable slide / stretch on the data to help align

- (IBAction)mergeDocs:(id)sender;
{
    NSLog(@"received the merge command");

    int result;
    NSSavePanel *sPanel = [NSSavePanel savePanel];

    result = [sPanel runModalForDirectory:nil file:@"merged.gc"];
    if ( result == NSOKButton) {
        // do some merging
        NSError *err;
        NSArray *samples = [xmlDocMaster nodesForXPath:@".//ride/samples[1]" error:&err];
        NSArray *samplesToAdd = [xmlDocSlave nodesForXPath:@".//ride/samples[1]" error:&err];

        if(err) {
            NSLog(@"%@",[err description]);
        }
        else {
            // for testing...get a sample:
            NSXMLNode *theNode = [[[samples objectAtIndex:0] children] lastObject];
            // then extract the "secs" attribute
            NSString *theSecs = [[[theNode nodesForXPath:@"@secs" error:nil] objectAtIndex:0] objectValue];
            NSLog(@"%@",theSecs);

            // add the slave samples to the master:
            NSXMLElement *sm = [samples objectAtIndex:0];

            // get the children and detach them from their tree:
            NSArray *smc = [[[samplesToAdd objectAtIndex:0] children] retain];
            [smc enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [(NSXMLNode*)obj detach];
            }];

            // use the keyPath to apply to all nodes:
            //NSLog(@"%@",[smc valueForKeyPath:@"secs.objectValue"]);

            double offsetSecs = self.manualOffsetSecs;

            // traverse the samples tree:
            NSXMLElement *sample = (NSXMLElement*)[sm childAtIndex:0];
            do {
                // NSLog(@"Looking for: %@",sample);
                // get the secs of this sample:
                float secs = [[[sample attributeForName:@"secs"] objectValue] floatValue];

                // lookup this secs in the slave tree, find a "close enough" match
                //  (use a 'price is right' model for now?)
                // assume that the records are already chronologically sorted
                // this whole thing is *highly* inefficient.
                [smc enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSXMLElement *s = (NSXMLElement*)obj;
                    float thisSec = [[[s attributeForName:@"secs"] objectValue] floatValue];
                    if (thisSec > secs + offsetSecs) {
                        //NSLog(@"Found: %@",s);

                        // assume that the PowerTap file is master
                        // then add the lat, lon and alt attributes, if present.
                        // TODO: what if the attributes are missing or already exist in the master sample?
                        NSXMLNode *lat;
                        NSXMLNode *lon;
                        NSXMLNode *alt;

                        // this is intended to deal with Mobile Logger often having
                        // several records at the beginning of the log without geo data.
                        @try {
                            lat = [[s attributeForName:@"lat"] copy];
                            lon = [[s attributeForName:@"lon"] copy];
                            alt = [[s attributeForName:@"alt"] copy];

                            [sample addAttribute:lat];
                            [sample addAttribute:lon];
                            [sample addAttribute:alt];

                            *stop = YES;
                        }
                        @catch (NSException * e) {
                            // the 'nearest' record in the slave samples
                            // doesn't have geo attributes - move to the next sample.
                            //NSLog(@"%@",[e description]);
                        }
                    }
                }];

            } while ( sample = (NSXMLElement*)[sample nextSibling] );

            // add the children to the other tree:
            // [sm insertChildren:smc atIndex:0];
            [smc release];

            // write out the newly merged tree to a file:
            NSString *aFile = [sPanel filename];
            NSFileManager *fm = [NSFileManager defaultManager];
            [fm createFileAtPath:aFile contents:[xmlDocMaster XMLData] attributes:nil];
        }
    }
}


@end
