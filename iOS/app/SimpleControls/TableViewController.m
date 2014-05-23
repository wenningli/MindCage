//
//  TableViewController.m
//  SimpleControl
//
//  Created by Cheong on 7/11/12.
//  Copyright (c) 2012 RedBearLab. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController (){
    NSString *myBlueSheildUUID;
    NSString *myBlueSheildUUID2;
    CBUUID *myUUIDA;
}

@end

@implementation TableViewController

@synthesize ble;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [[TGAccessoryManager sharedTGAccessoryManager] setupManagerWithInterval:0.08 ];
    
    [[TGAccessoryManager sharedTGAccessoryManager] setDelegate: self];
    
    if([[TGAccessoryManager sharedTGAccessoryManager] accessory] != nil)
        [[TGAccessoryManager sharedTGAccessoryManager] startStream];
    
    ble = [[BLE alloc] init];
    [ble controlSetup];
    ble.delegate = self;
    lblReceiveData.text = @"---";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BLE delegate

NSTimer *rssiTimer;

- (void)bleDidDisconnect
{
    NSLog(@"->Disconnected");
    
    [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    [indConnecting stopAnimating];
    
    
    swDigitalOut.enabled = false;
    swDigitalIn.enabled = false;

    sldPWM.enabled = false;
    sldServo.enabled = false;
    
    lblRSSI.text = @"---";
    //   lblAnalogIn.text = @"----";
    
    swReceiveData.enabled = false;
    lblReceiveData.enabled = false;
    
    [rssiTimer invalidate];
}

// When RSSI is changed, this will be called
-(void) bleDidUpdateRSSI:(NSNumber *) rssi
{
    lblRSSI.text = rssi.stringValue;
}

-(void) readRSSITimer:(NSTimer *)timer
{
    [ble readRSSI];
}

// When disconnected, this will be called
-(void) bleDidConnect
{
    NSLog(@"->Connected");
    
    [indConnecting stopAnimating];
    

    swDigitalOut.enabled = true;
    swDigitalIn.enabled = true;

    sldPWM.enabled = true;
    sldServo.enabled = true;
    
    swReceiveData.enabled = true;
    lblReceiveData.enabled = true;
    
    swDigitalOut.on = false;
    swDigitalIn.on = false;
    
    swReceiveData.on = false;

    sldPWM.value = 0;
    sldServo.value = 0;
    
    btnConnect.enabled = true;
    [btnConnect setTitle:@"Disconnct" forState:UIControlStateNormal];

    // send reset
    UInt8 buf[] = {0x04, 0x00, 0x00};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    
    // Schedule to read RSSI every 1 sec.
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length
{
    NSLog(@"Length: %d", length);
    
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3)
    {
        NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        
        if (data[i] == 0x0A)
        {
            if (data[i+1] == 0x01)
                swDigitalIn.on = true;
            else
                swDigitalIn.on = false;
        }
        else if (data[i] == 0x0B)
        {
            UInt16 Value;
            
            Value = data[i+2] | data[i+1] << 8;
            
          

        }
    }
}

#pragma mark - Actions

// Connect button will call to this
- (IBAction)btnScanForPeripherals:(id)sender
{
    
   // if ([[TGAccessoryManager sharedTGAccessoryManager] accessory ] != nil){
     //   [[TGAccessoryManager sharedTGAccessoryManager] startStream];
    //}
    
    
    
    if (ble.activePeripheral)
        if(ble.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
            NSLog(@"Disconnect");
            return;
        }
    
    if (ble.peripherals)
        ble.peripherals = nil;
    
    [btnConnect setEnabled:false];
    [ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [indConnecting startAnimating];
}

-(void) connectionTimer:(NSTimer *)timer{
    if (ble.peripherals.count > 0)
        
        for(int i = 0; i < ble.peripherals.count; i++)
            
        {
            
            //////////////////////////////////////////////////////////
            
            //  PUT YOUR BLE SHEILD UUID HERE, Check DeBug Log Below For Available UUID's
            
            // example:  @"26E96EC3-AA39-CE03-C04B-8E704D8A51C7";
            
            //////////////////////////////////////////////////////////
            
            
            myBlueSheildUUID = @"713D0000-503E-4C75-BA94-3148F18D941E";
            myBlueSheildUUID2 = @"17D55FCD-F9C0-7390-6B0F-70A271A162B2";

            
            myUUIDA = [CBUUID UUIDWithString:myBlueSheildUUID];

            
            
            
            
            CBPeripheral *p = [ble.peripherals objectAtIndex:i];
            
            NSMutableString * pUUIDString = [[NSMutableString alloc] initWithFormat:@"%@",CFUUIDCreateString(NULL, p.UUID) ];
            
            // Debug Line
            
            // NSLog(@"\n++++++\nLooking for your perfered Device UUID of: %@\n", myBlueSheildUUID);
            
            
            
            // Debug Line
            
            //NSLog(@" pUUIDString is: %@\n", pUUIDString);
            
            
            
            if ([myBlueSheildUUID isEqualToString:pUUIDString] ) {
                
                NSLog(@"\n\n++++++   Found your Perfered Device UUID of: %@\n\n", myBlueSheildUUID);
                
                [ble connectPeripheral:[ble.peripherals objectAtIndex:i]];
                continue;
                
                
            }
            if ([myBlueSheildUUID2 isEqualToString:pUUIDString] ) {
                
                NSLog(@"\n\n++++++   Found your Perfered Device UUID of: %@\n\n", myBlueSheildUUID2);
                
                [ble connectPeripheral:[ble.peripherals objectAtIndex:i]];
                continue;
                
                
            }

            
            if (![myBlueSheildUUID isEqualToString:pUUIDString]) {
                
                NSLog(@"Found a Bluetooth Device, But doesn't match your UUID \n\n");
                
                
                
            }    }
    
}


-(IBAction)sendDigitalOut:(id)sender
{
    UInt8 buf[3] = {0x01, 0x00, 0x00};
    
    if (swDigitalOut.on)
        buf[1] = 0x01;
    else
        buf[1] = 0x00;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

/* Send command to Arduino to enable analog reading */

// PWM slide will call this to send its value to Arduino
-(IBAction)sendPWM:(id)sender
{
    UInt8 buf[3] = {0x02, 0x00, 0x00};  //pin 6
    
    buf[1] = sldPWM.value;
    buf[2] = (int)sldPWM.value >> 8;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

// Servo slider will call this to send its value to Arduino
-(IBAction)sendServo:(id)sender
{
    UInt8 buf[3] = {0x03, 0x00, 0x00};  //pin 7
    
    buf[1] = sldServo.value;
    buf[2] = (int)sldServo.value >> 8;
    NSLog(@"Servo value %f",sldServo.value);
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

#pragma mark -
#pragma mark TGAccessoryDelegate protocol methods


- (void)accessoryDidConnect:(EAAccessory *)accessory {
    NSLog(@"MindWave connected");
    
    [[TGAccessoryManager sharedTGAccessoryManager] startStream];
    
}

//  This method gets called by the TGAccessoryManager when a ThinkGear-enabled
//  accessory is disconnected.
- (void)accessoryDidDisconnect {
    NSLog(@"Mindwave disconnect");

}

//  This method gets called by the TGAccessoryManager when data is received from the
//  ThinkGear-enabled device.
- (void)dataReceived:(NSDictionary *)data {
    [data retain];
    if([data valueForKey:@"eSenseAttention"]){
        
        int nAttention =    [[data valueForKey:@"eSenseAttention"] intValue];
        lblReceiveData.text = [NSString stringWithFormat:@"%d", nAttention];
        float fontSize = 7 + (107-7) * ((float)nAttention/100.0);
        [lblReceiveData setFont:[UIFont systemFontOfSize:fontSize]];
        if (nAttention >= 60)
        {
            [lblReceiveData setTextColor:[UIColor redColor]];
        }
        else
        {
            [lblReceiveData setTextColor:[UIColor blackColor]];
        }
        NSLog(@"eSenseValues.attention %d", nAttention);
        UInt8 buf[3] = {0x03, 0x5f, 0x00};
        buf[1] = (UInt8)nAttention;
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [ble write:data];

        /*
        if (nAttention > 50)
        {
            //stop
            UInt8 buf[3] = {0x03, 0x5f, 0x00};
            NSData *data = [[NSData alloc] initWithBytes:buf length:3];
            [ble write:data];
            NSLog(@"stop");
   
        }
        else if (nAttention<30)
        {
            UInt8 buf[3] = {0x03, 0x00, 0x00};
            
            buf[1] = sldServo.value;
            buf[2] = (int)sldServo.value >> 8;
            NSLog(@"resume");
            NSData *data = [[NSData alloc] initWithBytes:buf length:3];
            [ble write:data];
        }
        */
        prevAttention = nAttention;
        
    }
    
    [data release];
    return;
    NSString * temp = [[NSString alloc] init];
    NSDate * date = [NSDate date];
    
    if([data valueForKey:@"blinkStrength"])
        blinkStrength = [[data valueForKey:@"blinkStrength"] intValue];
    
    if([data valueForKey:@"raw"]) {
        rawValue = [[data valueForKey:@"raw"] shortValue];
    }
    
    if([data valueForKey:@"heartRate"])
        heartRate = [[data valueForKey:@"heartRate"] intValue];
    
    if([data valueForKey:@"poorSignal"]) {
        poorSignalValue = [[data valueForKey:@"poorSignal"] intValue];
        temp = [temp stringByAppendingFormat:@"%f: Poor Signal: %d\n", [date timeIntervalSince1970], poorSignalValue];

        buffRawCount = 0;
    }
    
    if([data valueForKey:@"respiration"]) {
        respiration = [[data valueForKey:@"respiration"] floatValue];
    }
    
    if([data valueForKey:@"heartRateAverage"]) {
        heartRateAverage = [[data valueForKey:@"heartRateAverage"] intValue];
    }
    if([data valueForKey:@"heartRateAcceleration"]) {
        heartRateAcceleration = [[data valueForKey:@"heartRateAcceleration"] intValue];
    }
    
    if([data valueForKey:@"rawCount"]) {
        rawCount = [[data valueForKey:@"rawCount"] intValue];
    }
    
    
    // check to see whether the eSense values are there. if so, we assume that
    // all of the other data (aside from raw) is there. this is not necessarily
    // a safe assumption.
    if([data valueForKey:@"eSenseAttention"]){
        
        eSenseValues.attention =    [[data valueForKey:@"eSenseAttention"] intValue];
        
        NSLog(@"eSenseValues.attention %d", eSenseValues.attention);
        
    //lblReceiveData.text = [NSString stringWithFormat:@"%d", eSenseValues.attention];
        
        eSenseValues.meditation =   [[data valueForKey:@"eSenseMeditation"] intValue];
        
        temp = [temp stringByAppendingFormat:@"%f: Attention: %d\n", [date timeIntervalSince1970], eSenseValues.attention];
        temp = [temp stringByAppendingFormat:@"%f: Meditation: %d\n", [date timeIntervalSince1970], eSenseValues.meditation];
        
        eegValues.delta =       [[data valueForKey:@"eegDelta"] intValue];
        eegValues.theta =       [[data valueForKey:@"eegTheta"] intValue];
        eegValues.lowAlpha =    [[data valueForKey:@"eegLowAlpha"] intValue];
        eegValues.highAlpha =   [[data valueForKey:@"eegHighAlpha"] intValue];
        eegValues.lowBeta =     [[data valueForKey:@"eegLowBeta"] intValue];
        eegValues.highBeta =    [[data valueForKey:@"eegHighBeta"] intValue];
        eegValues.lowGamma =    [[data valueForKey:@"eegLowGamma"] intValue];
        eegValues.highGamma =   [[data valueForKey:@"eegHighGamma"] intValue];
        
    }
  //  [data release];


}
- (IBAction)receiveData:(id)sender {
    
    UInt8 buf[3] = {0xA0, 0x00, 0x00};
    
    if (swReceiveData.on)
        buf[1] = 0x01;
    else
        buf[1] = 0x00;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
    
}



@end