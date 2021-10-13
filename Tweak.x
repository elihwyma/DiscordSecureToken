@import Foundation;

%hook NSUserDefaults

- (instancetype)initWithSuiteName:(NSString *)suitename {
	NSUserDefaults *orig = %orig;
	if ([suitename isEqualToString: @"group.com.hammerandchisel.discord"]) {
		[orig removeObjectForKey: @"_authenticationTokenKey"];
	}
	return orig;
}

- (void)setObject:(id)value forKey:(NSString *)defaultName {
	if ([defaultName isEqualToString: @"_authenticationTokenKey"]) {
		return;	
	}
	%orig;
}

%end