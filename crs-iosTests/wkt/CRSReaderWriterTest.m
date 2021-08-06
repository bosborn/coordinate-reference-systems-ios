//
//  CRSReaderWriterTest.m
//  crs-iosTests
//
//  Created by Brian Osborn on 8/5/21.
//  Copyright © 2021 NGA. All rights reserved.
//

#import "CRSReaderWriterTest.h"
#import "CRSTestUtils.h"
#import "CRSReader.h"
#import "CRSWriter.h"

@implementation CRSReaderWriterTest

/**
 * Test scope
 */
-(void) testScope{
    
    NSString *text = @"SCOPE[\"Large scale topographic mapping and cadastre.\"]";
    CRSReader *reader = [CRSReader createWithText:text];
    NSString *scope = [reader readScope];
    [CRSTestUtils assertNotNil:scope];
    [CRSTestUtils assertEqualWithValue:@"Large scale topographic mapping and cadastre." andValue2:scope];
    CRSWriter *writer = [CRSWriter create];
    [writer writeScope:scope];
    [CRSTestUtils assertEqualWithValue:text andValue2:[writer description]];
    
}

/**
 * Test area description
 */
-(void) testAreaDescription{
    
    NSString *text = @"AREA[\"Netherlands offshore.\"]";
    CRSReader *reader = [CRSReader createWithText:text];
    NSString *areaDescription = [reader readAreaDescription];
    [CRSTestUtils assertNotNil:areaDescription];
    [CRSTestUtils assertEqualWithValue:@"Netherlands offshore." andValue2:areaDescription];
    CRSWriter *writer = [CRSWriter create];
    [writer writeAreaDescription:areaDescription];
    [CRSTestUtils assertEqualWithValue:text andValue2:[writer description]];
    
}

/**
 * Test geographic bounding box
 */
-(void) testGeographicBoundingBox{
    
    NSString *text = @"BBOX[51.43,2.54,55.77,6.40]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSGeographicBoundingBox *boundingBox = [reader readGeographicBoundingBox];
    [CRSTestUtils assertNotNil:boundingBox];
    [CRSTestUtils assertEqualDoubleWithValue:51.43 andValue2:boundingBox.lowerLeftLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:2.54 andValue2:boundingBox.lowerLeftLongitude];
    [CRSTestUtils assertEqualDoubleWithValue:55.77 andValue2:boundingBox.upperRightLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:6.40 andValue2:boundingBox.upperRightLongitude];
    [CRSTestUtils assertEqualWithValue:[text stringByReplacingOccurrencesOfString:@".40" withString:@".4"]
                             andValue2:[boundingBox description]];
    
    text = @"BBOX[-55.95,160.60,-25.88,-171.20]";
    reader = [CRSReader createWithText:text];
    boundingBox = [reader readGeographicBoundingBox];
    [CRSTestUtils assertNotNil:boundingBox];
    [CRSTestUtils assertEqualDoubleWithValue:-55.95 andValue2:boundingBox.lowerLeftLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:160.60 andValue2:boundingBox.lowerLeftLongitude];
    [CRSTestUtils assertEqualDoubleWithValue:-25.88 andValue2:boundingBox.upperRightLatitude];
    [CRSTestUtils assertEqualDoubleWithValue:-171.20 andValue2:boundingBox.upperRightLongitude];
    [CRSTestUtils assertEqualWithValue:[[text stringByReplacingOccurrencesOfString:@".60" withString:@".6"]
                                        stringByReplacingOccurrencesOfString:@".20" withString:@".2"]
                             andValue2:[boundingBox description]];
    
}

/**
 * Test vertical extent
 */
-(void) testVerticalExtent{
    
    NSString *text = @"VERTICALEXTENT[-1000,0,LENGTHUNIT[\"metre\",1.0]]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSVerticalExtent *verticalExtent = [reader readVerticalExtent];
    [CRSTestUtils assertNotNil:verticalExtent];
    [CRSTestUtils assertEqualDoubleWithValue:-1000 andValue2:verticalExtent.minimumHeight];
    [CRSTestUtils assertEqualDoubleWithValue:0 andValue2:verticalExtent.maximumHeight];
    CRSUnit *lengthUnit = verticalExtent.unit;
    [CRSTestUtils assertNotNil:lengthUnit];
    [CRSTestUtils assertEqualIntWithValue:CRS_UNIT_LENGTH andValue2:lengthUnit.type];
    [CRSTestUtils assertEqualWithValue:@"metre" andValue2:lengthUnit.name];
    [CRSTestUtils assertEqualDoubleWithValue:1.0 andValue2:[lengthUnit.conversionFactor doubleValue]];
    text = [text stringByReplacingOccurrencesOfString:@"-1000,0" withString:@"-1000.0,0.0"];
    [CRSTestUtils assertEqualWithValue:text andValue2:[verticalExtent description]];
    
    text = @"VERTICALEXTENT[-1000,0]";
    reader = [CRSReader createWithText:text];
    verticalExtent = [reader readVerticalExtent];
    [CRSTestUtils assertNotNil:verticalExtent];
    [CRSTestUtils assertEqualDoubleWithValue:-1000 andValue2:verticalExtent.minimumHeight];
    [CRSTestUtils assertEqualDoubleWithValue:0 andValue2:verticalExtent.maximumHeight];
    lengthUnit = verticalExtent.unit;
    [CRSTestUtils assertNil:lengthUnit];
    text = [text stringByReplacingOccurrencesOfString:@"-1000,0" withString:@"-1000.0,0.0"];
    [CRSTestUtils assertEqualWithValue:text andValue2:[verticalExtent description]];
    
}

/**
 * Test temporal extent
 */
-(void) testTemporalExtent{
    
    NSString *text = @"TIMEEXTENT[2013-01-01,2013-12-31]";
    CRSReader *reader = [CRSReader createWithText:text];
    CRSTemporalExtent *temporalExtent = [reader readTemporalExtent];
    [CRSTestUtils assertNotNil:temporalExtent];
    [CRSTestUtils assertEqualWithValue:@"2013-01-01" andValue2:temporalExtent.start];
    [CRSTestUtils assertTrue:[temporalExtent hasStartDateTime]];
    [CRSTestUtils assertEqualWithValue:@"2013-01-01" andValue2:[temporalExtent.startDateTime description]];
    [CRSTestUtils assertEqualWithValue:@"2013-12-31" andValue2:temporalExtent.end];
    [CRSTestUtils assertTrue:[temporalExtent hasEndDateTime]];
    [CRSTestUtils assertEqualWithValue:@"2013-12-31" andValue2:[temporalExtent.endDateTime description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalExtent description]];
    
    text = @"TIMEEXTENT[\"Jurassic\",\"Quaternary\"]";
    reader = [CRSReader createWithText:text];
    temporalExtent = [reader readTemporalExtent];
    [CRSTestUtils assertNotNil:temporalExtent];
    [CRSTestUtils assertEqualWithValue:@"Jurassic" andValue2:temporalExtent.start];
    [CRSTestUtils assertFalse:[temporalExtent hasStartDateTime]];
    [CRSTestUtils assertEqualWithValue:@"Quaternary" andValue2:temporalExtent.end];
    [CRSTestUtils assertFalse:[temporalExtent hasEndDateTime]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[temporalExtent description]];
    
}

/**
 * Test usage
 */
-(void) testUsage{

    NSMutableString *text = [NSMutableString string];
    [text appendString:@"USAGE[SCOPE[\"Spatial referencing.\"],"];
    [text appendString:@"AREA[\"Netherlands offshore.\"],TIMEEXTENT[1976-01,2001-04]]"];
    CRSReader *reader = [CRSReader createWithText:text];
    CRSUsage *usage = [reader readUsage];
    [CRSTestUtils assertNotNil:usage];
    [CRSTestUtils assertEqualWithValue:@"Spatial referencing." andValue2:usage.scope];
    CRSExtent *extent = usage.extent;
    [CRSTestUtils assertNotNil:extent];
    [CRSTestUtils assertEqualWithValue:@"Netherlands offshore." andValue2:extent.areaDescription];
    CRSTemporalExtent *temporalExtent = extent.temporalExtent;
    [CRSTestUtils assertNotNil:temporalExtent];
    [CRSTestUtils assertEqualWithValue:@"1976-01" andValue2:temporalExtent.start];
    [CRSTestUtils assertTrue:[temporalExtent hasStartDateTime]];
    [CRSTestUtils assertEqualWithValue:@"1976-01" andValue2:[temporalExtent.startDateTime description]];
    [CRSTestUtils assertEqualWithValue:@"2001-04" andValue2:temporalExtent.end];
    [CRSTestUtils assertTrue:[temporalExtent hasEndDateTime]];
    [CRSTestUtils assertEqualWithValue:@"2001-04" andValue2:[temporalExtent.endDateTime description]];
    [CRSTestUtils assertEqualWithValue:text andValue2:[usage description]];

}

@end