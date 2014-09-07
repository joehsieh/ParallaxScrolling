/*
 JHUtility.m
 Copyright (C) 2014 Joe Hsieh
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "JHUtility.h"

@implementation JHUtility
@end

@implementation JHUtility (JSON)

+ (id)convertJSONStringToObject:(NSString *)inJSONString
{
	NSAssert(inJSONString, @"JSON string must exist");
	NSAssert(![inJSONString isKindOfClass:[NSNull class]], @"JSON string must not be NSNull");
	NSAssert([inJSONString length] != 0, @"JSON string must not be empty string");
	NSData* data = [inJSONString dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
	NSAssert(!error, @"Convert json string to object must succeed");
	return object;
}

+ (NSString *)convertObjectToJSONString:(id)inObject
{
	if (inObject == nil || [inObject isKindOfClass:[NSNull class]]) {
		return @"";
	}
	NSError *error;
	NSData *JSONData = [NSJSONSerialization dataWithJSONObject:inObject
													   options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
														 error:&error];
	NSAssert(!error, @"Convert object to json string must succeed");
	NSString *JSONString = @"";
	if (JSONData) {
		JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
	}
	return JSONString;
}

@end
