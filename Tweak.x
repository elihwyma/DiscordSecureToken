@import Foundation;

void setToken(NSString *token) {
	NSDictionary *query = @{
		(id)kSecClass: (id)kSecClassInternetPassword,
		(id)kSecAttrAccount: @"_discordSecureToken",
		(id)kSecAttrAccessGroup: @"group.com.hammerandchisel.discord",
		(id)kSecValueData: [token dataUsingEncoding:NSUTF8StringEncoding]
	};
	SecItemDelete((CFDictionaryRef)query);
	OSStatus status = SecItemAdd((CFDictionaryRef)query, NULL);
	if (status != noErr) {
		NSLog(@"[Discord] Error = %@", [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
	}
}

void deleteToken() {
	NSDictionary *query = @{
		(id)kSecClass: (id)kSecClassInternetPassword,
		(id)kSecAttrAccount: @"_discordSecureToken",
		(id)kSecAttrAccessGroup: @"group.com.hammerandchisel.discord",
	};
	SecItemDelete((CFDictionaryRef)query);
}

NSString *getToken() {
	NSDictionary *query = @{
        (id)kSecClass: (id)kSecClassInternetPassword,
        (id)kSecAttrAccount: @"_discordSecureToken",
		(id)kSecAttrAccessGroup: @"group.com.hammerandchisel.discord",
        (id)kSecReturnData: @YES
    };

	CFTypeRef dataTypeRef = NULL;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, &dataTypeRef);
	NSData *data = (__bridge_transfer NSData *)dataTypeRef;
	
    if(status != noErr)
    {
        NSLog(@"[Discord] Error = %@", [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil]);
        return nil;
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

%hook NSUserDefaults

- (instancetype)initWithSuiteName:(NSString *)suitename {
	NSUserDefaults *orig = %orig;
	if ([suitename isEqualToString: @"group.com.hammerandchisel.discord"]) {
		NSString *token = [orig stringForKey: @"_authenticationTokenKey_orig"];
		if (token) {
			setToken(token);
		}
		[orig removeObjectForKey: @"_authenticationTokenKey_orig"];
	}
	return orig;
}

- (NSString *)stringForKey:(NSString *)defaultName {
	if ([defaultName isEqualToString: @"_authenticationTokenKey"]) {
		return getToken();
	} else if ([defaultName isEqualToString: @"_authenticationTokenKey_orig"]) {
		return %orig(@"_authenticationTokenKey");
	}
	return %orig;
}

- (id)objectForKey:(NSString *)defaultName {
	if ([defaultName isEqualToString: @"_authenticationTokenKey"]) {
		return getToken();
	}
	return %orig;
}

- (void)setObject:(id)value forKey:(NSString *)defaultName {
	if ([defaultName isEqualToString: @"_authenticationTokenKey"]) {
		NSString *token = value;
		if (token) {
			setToken(token);
		} else {
			%orig;
			deleteToken();
		}
		return;	
	} else if ([defaultName isEqualToString: @"_authenticationTokenKey_orig"]) {
		%orig(value, @"_authenticationTokenKey");
		return;
	}
	%orig;
}

%end
