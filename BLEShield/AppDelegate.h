//
//  AppDelegate.h
//  BLEShield
//
//  Created by Khaos Tian on 9/15/12.
//  Copyright (c) 2012 Oltica. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>{
    CBCentralManager *manager;
    CBPeripheral *peripheral;
    NSMutableData *finaldata;
        
    CBCharacteristic *write;
    CBCharacteristic *wb;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)Connect:(id)sender;
@property (weak) IBOutlet NSButton *Button;
- (IBAction)disconnect:(id)sender;
@property (unsafe_unretained) IBOutlet NSTextView *TextView;
@property (weak) IBOutlet NSTextFieldCell *RSSIText;
@property (weak) IBOutlet NSButton *DisconnectButton;
@property (weak) IBOutlet NSTextField *WriteField;
- (IBAction)WriteData:(id)sender;

@end
