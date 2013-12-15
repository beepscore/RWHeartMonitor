//
//  HRMViewController.m
//  HeartMonitor
//
//  Created by Main Account on 12/13/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import "HRMViewController.h"

@interface HRMViewController ()

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *polarH7HRMPeripheral;

@property (nonatomic, weak) IBOutlet UIImageView *heartImage;
@property (nonatomic, weak) IBOutlet UITextView *deviceInfo;

// data characteristics for peripheral device
// TODO: Consider move these to a model object
@property (nonatomic, strong) NSString *connected;
@property (nonatomic, strong) NSString *bodyData;
@property (nonatomic, strong) NSString *manufacturer;
@property (nonatomic, strong) NSString *polarH7DeviceData;
@property (assign) uint16_t heartRate;

@property (nonatomic, strong) UILabel *heartRateBPM;
@property (nonatomic, retain) NSTimer *pulseTimer;

@end

@implementation HRMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	self.polarH7DeviceData = nil;
	[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	[self.heartImage setImage:[UIImage imageNamed:@"HeartImage"]];

	// Clear out textView
	[self.deviceInfo setText:@""];
	[self.deviceInfo setTextColor:[UIColor blueColor]];
	[self.deviceInfo setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
	[self.deviceInfo setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:25]];
	[self.deviceInfo setUserInteractionEnabled:NO];

	// Create your Heart Rate BPM Label
	self.heartRateBPM = [[UILabel alloc] initWithFrame:CGRectMake(55, 30, 75, 50)];
	[self.heartRateBPM setTextColor:[UIColor whiteColor]];
	[self.heartRateBPM setText:[NSString stringWithFormat:@"%i", 0]];
	[self.heartRateBPM setFont:[UIFont fontWithName:@"Futura-CondensedMedium" size:28]];
	[self.heartImage addSubview:self.heartRateBPM];

	// Scan for all available CoreBluetooth LE devices
	self.centralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                               queue:nil];
	NSArray *services = @[[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID],
                          [CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]];
	[self.centralManager scanForPeripheralsWithServices:services options:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark CBCentralManagerDelegate

// method called whenever you have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    self.connected = [NSString stringWithFormat:@"Connected: %@",
                      peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
    NSLog(@"%@", self.connected);
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter.
// This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if ([localName length] > 0) {
        NSLog(@"Found the heart rate monitor: %@", localName);
        [self.centralManager stopScan];
        self.polarH7HRMPeripheral = peripheral;
        peripheral.delegate = self;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

// method called whenever the device state changes
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Determine the state of the peripheral
    if ([central state] == CBCentralManagerStatePoweredOff) {
        NSLog(@"CoreBluetooth BLE hardware is powered off");
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
    }
    else if ([central state] == CBCentralManagerStateUnauthorized) {
        NSLog(@"CoreBluetooth BLE state is unauthorized");
    }
    else if ([central state] == CBCentralManagerStateUnknown) {
        NSLog(@"CoreBluetooth BLE state is unknown");
    }
    else if ([central state] == CBCentralManagerStateUnsupported) {
        NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
    }
}

#pragma mark CBPeripheralDelegate

// Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service: %@", service.UUID);
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// invoked when you discover the characteristics of a specified service
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_HEART_RATE_SERVICE_UUID]])  {

        for (CBCharacteristic *aChar in service.characteristics)
        {
            // Request heart rate notifications
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID]]) {
                // request peripheral start providing notifications
                // peripheral calls delegate method
                // peripheral:didUpdateNotificationStateForCharacteristic:error:
                // if peripheral starts notifications, whenever value changes it calls
                // peripheral:didUpdateValueForCharacteristic:error:
                [self.polarH7HRMPeripheral setNotifyValue:YES forCharacteristic:aChar];
                NSLog(@"Found heart rate measurement characteristic");
            }
            // Request body sensor location
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID]]) {
                // body location doesn't change, so just read it once, don't subscribe
                [self.polarH7HRMPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found body sensor location characteristic");
            }
        }
    }

    // Retrieve Device Information Services for the Manufacturer Name
    if ([service.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_DEVICE_INFO_SERVICE_UUID]])  {

        for (CBCharacteristic *aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID]]) {
                [self.polarH7HRMPeripheral readValueForCharacteristic:aChar];
                NSLog(@"Found a device manufacturer name characteristic");
            }
        }
    }
}

// invoked when you retrieve a specified characteristic's value,
// or when the peripheral device notifies your app that the charactteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
    // Updated value for heart rate measurement received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID]]) {
        // Get the Heart Rate Monitor BPM
        [self getHeartBPMData:characteristic error:error];
    }
    // Retrieve the characteristic value for manufacturer name received
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID]]) {
        [self getManufacturerName:characteristic];
    }
    // Retrieve the characteristic value for the body sensor location received
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID]]) {
        [self getBodyLocation:characteristic];
    }

    // Add your constructed device information to your UITextView
    self.deviceInfo.text = [NSString stringWithFormat:@"%@\n%@\n%@\n", self.connected, self.bodyData, self.manufacturer];
}

# pragma mark - CBCharacteristic helpers

// Heart rate BPM info
- (void)getHeartBPMData:(CBCharacteristic *)characteristic
                  error:(NSError *)error
{
    NSData *data = [characteristic value];
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;

    // Retrieve the BPM value for the Heart Rate Monitor
    // check reportData first byte, first bit. (Mask all but first bit.)
    if ((reportData[0] & 0x01) == 0) {
        // set bpm to reportData to second byte
        bpm = reportData[1];
    }
    else {
        // CFSwapInt16LittleToHost converts little endian to native, may swap bytes
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
    }
    // Display the heart rate value to the UI if no error occurred
    if( (characteristic.value)  || !error ) {
        self.heartRate = bpm;
        self.heartRateBPM.text = [NSString stringWithFormat:@"%i bpm", bpm];
        self.heartRateBPM.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:28];
        [self doHeartBeat];

        self.pulseTimer = [NSTimer scheduledTimerWithTimeInterval:(60. / self.heartRate)
                                                           target:self
                                                         selector:@selector(doHeartBeat)
                                                         userInfo:nil
                                                          repeats:NO];
    }
    return;
}

// manufacturer of device
- (void)getManufacturerName:(CBCharacteristic *)characteristic
{

}

// body location
- (void)getBodyLocation:(CBCharacteristic *)characteristic
{

}

// perform heart beat animation
- (void)doHeartBeat
{

}

@end
