//
//  AppDelegate.m
//  BLEShield
//
//  Created by Khaos Tian on 9/15/12.
//  Copyright (c) 2012 Oltica. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize TextView;
@synthesize RSSIText;
@synthesize DisconnectButton;
@synthesize Button;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    finaldata = [[NSMutableData alloc]init];
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_current_queue()];
    // Insert code here to initialize your application
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"%ld",[manager state]);
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    RSSIText.title = [NSString stringWithFormat:@"%@",RSSI];
    NSLog(@"%@",[advertisementData description]);
    //if ([RSSI floatValue]>=-45.f) {
        //NSLog(@"Greater than 45");
        [central stopScan];
        peripheral = aPeripheral;
        [central connectPeripheral:peripheral options:nil];
    //}
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Failed:%@",error);
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{    
    NSLog(@"Connected:%@",aPeripheral.UUID);
    [TextView insertText:[NSString stringWithFormat:@"Connected:%@\n",aPeripheral.UUID]];
    [DisconnectButton setEnabled:YES];
    Button.title = @"Connected";
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:nil];
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Disconnected");
    [TextView insertText:@"Disconnected\n"];
    [DisconnectButton setEnabled:NO];
    Button.title = @"Connect";
    [finaldata setLength:0];
    [Button setEnabled:YES];
    [manager stopScan];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error {
    for (CBService *aService in aPeripheral.services){
        //if ([aService.UUID isEqual:[CBUUID UUIDWithString:@"0A12"]]) {
            [aPeripheral discoverCharacteristics:nil forService:aService];
        //}
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *aChar in service.characteristics){
        NSLog(@"%@",aChar.UUID);
        NSLog(@"%lu",aChar.properties);
        
        //Write
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"713D0003-503E-4C75-BA94-3148F18D941E"]]) {
            write = aChar;
            NSString *mainString = [NSString stringWithFormat:@"Hola12345\r\n"];
            NSData *mainData= [mainString dataUsingEncoding:NSUTF8StringEncoding];
            [aPeripheral writeValue:mainData forCharacteristic:aChar type:CBCharacteristicWriteWithResponse];
        }
        
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"713D0004-503E-4C75-BA94-3148F18D941E"]]) {
            wb = aChar;
        }
        
        [TextView insertText:[NSString stringWithFormat:@"Characteristic UUID:%@\n",aChar.UUID]];
        
        if ([aChar.UUID isEqual:[CBUUID UUIDWithString:@"713D0002-503E-4C75-BA94-3148F18D941E"]]) {
            [aPeripheral setNotifyValue:YES forCharacteristic:aChar];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"Finish Write\n");
    [TextView insertText:@"Finish Write\n"];
}

- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData * updatedValue = characteristic.value;
    NSLog(@"%@",[[NSString alloc]initWithData:updatedValue encoding:NSUTF8StringEncoding]);
    NSString *mainString = [NSString stringWithFormat:@"1"];
    NSData *mainData= [mainString dataUsingEncoding:NSUTF8StringEncoding];
    [aPeripheral writeValue:mainData forCharacteristic:wb type:CBCharacteristicWriteWithResponse];
}

- (IBAction)Connect:(id)sender {
    [manager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:YES] }];
    Button.title = @"Scanning";
    [Button setEnabled:NO];
}

- (IBAction)disconnect:(id)sender {
    [manager cancelPeripheralConnection:peripheral];
}
- (IBAction)WriteData:(id)sender {
    NSString *mainString = [NSString stringWithFormat:@"%@\r\n",_WriteField.stringValue];
    _WriteField.stringValue = @"";
    NSData *mainData= [mainString dataUsingEncoding:NSUTF8StringEncoding];
    [peripheral writeValue:mainData forCharacteristic:write type:CBCharacteristicWriteWithResponse];
}
@end
