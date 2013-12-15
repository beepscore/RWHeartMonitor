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

}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter.
// This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{

}

// method called whenever the device state changes
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{

}

#pragma mark CBPeripheralDelegate

// Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{

}

// invoked when you discover the characteristics of a specified service
- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{

}

// invoked when you retrieve a specified characteristic's value,
// or when the peripheral device notifies your app that the charactteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{

}

# pragma mark - CBCharacteristic helpers

// Heart rate BPM info
- (void)getHeartBPMData:(CBCharacteristic *)characteristic
                      error:(NSError *)error
{

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
