//
//  CLLocationPrivate.h
//  Water Filter
//
//  Created by Glenn on 3/26/21.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLLocation ()

- (int)type;

//Type 1: GPS
//Type 2: NMEA
//Type 3: Accessory
//Type 4: WiFi
//Type 5: Skyhook (obsolete?)
//Type 6: Cellular
//Type 7: Cell LAC
//Type 8: Cell MCC
//Type 9: Indoor
//Type 10: GPS Coarse
//Type 12: No precise?

@end

NS_ASSUME_NONNULL_END
