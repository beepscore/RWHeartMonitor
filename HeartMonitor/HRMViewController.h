//
//  HRMViewController.h
//  HeartMonitor
//
//  Created by Main Account on 12/13/13.
//  Copyright (c) 2013 Razeware LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreBluetooth;
@import QuartzCore;

// https://developer.bluetooth.org/gatt/services/Pages/ServicesHome.aspx
#define POLARH7_HRM_DEVICE_INFO_SERVICE_UUID @"180A"
#define POLARH7_HRM_HEART_RATE_SERVICE_UUID @"180D"

// https://developer.bluetooth.org/gatt/characteristics/Pages/CharacteristicsHome.aspx
#define POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID @"2A37"
#define POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID @"2A38"
#define POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID @"2A29"

@interface HRMViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

// Heart rate BPM info
- (void)getHeartBPMData:(CBCharacteristic *)characteristic
                  error:(NSError *)error;

// manufacturer of device
- (void)getManufacturerName:(CBCharacteristic *)characteristic;

// body location
- (void)getBodyLocation:(CBCharacteristic *)characteristic;

// perform heart beat animation
- (void)doHeartBeat;

@end
