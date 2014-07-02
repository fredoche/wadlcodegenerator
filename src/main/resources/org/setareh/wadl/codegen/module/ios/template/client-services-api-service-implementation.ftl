[#ftl]
#import "${className}Api.h"
#import "${generatedPrefix}File.h"
#import "${generatedPrefix}ApiClient.h"
[#list imports as import]
#import "${import}"
[/#list]

@interface ${className}Api ()

@property(nonatomic, copy) NSString * basePath;
@property(nonatomic, copy) NSString * group;

@end

@implementation ${className}Api

+ (${className}Api*) sharedApiWithBasePath:(NSString *) basePath {
    return [${className}Api sharedApiWithBasePath:basePath withGroup:nil];
}

+ (${className}Api*) sharedApiWithBasePath:(NSString *) basePath  withGroup:(NSString *)group {
    static ${className}Api* singletonAPI = nil;

    if (singletonAPI == nil) {
        singletonAPI = [[${className}Api alloc] initWithBasePath:basePath group:group];
    }
    return singletonAPI;
}

-(${generatedPrefix}ApiClient*) apiClient {
    return [${generatedPrefix}ApiClient sharedClientFromPool:self.basePath withGroup:self.group];
}

-(void) addHeader:(NSString*)value forKey:(NSString*)key {
    [[self apiClient] setHeaderValue:value forKey:key];
}

-(id) initWithBasePath:basePath group:group {
    self = [super init];

    self.basePath = basePath;
    self.group = group;

    [self apiClient];

    return self;
}

-(void) setHeaderValue:(NSString*) value forKey:(NSString*)key {
    [[self apiClient] setHeaderValue:value forKey:key];
}

-(unsigned long) requestQueueSize {
    return [${generatedPrefix}ApiClient requestQueueSize];
}

-(void) setAuthenticationLogin:(NSString*) login andPassword:(NSString*)password {
    [[self apiClient] setAuthenticationLogin:login andPassword:password];
}

- (void)setAuthorizationWithBlock:(NSString *(^)(NSURL *, NSString * method, NSData *body))authorizationBlock {
    [[self apiClient] setAuthorizationWithBlock:authorizationBlock];
}

[#list methods as method]
-(NSNumber*) ${method.name}With[#if method.request??]CompletionBlock:(${projectPrefix}${method.request.name}*) body
[/#if][#if method.requestParams??][#list method.requestParams as param]param${param.name}: (NSString *) ${param.name} [/#list][/#if]completionHandler: (void (^)(${projectPrefix}${method.response.name}* output, NSError* error[#compress]
    [#list method.faults as fault]
        , ${projectPrefix}${fault.name} *${fault.name?uncap_first}Response
    [/#list]
[/#compress]))completionBlock{

    NSMutableString* requestUrl = [NSMutableString stringWithFormat:@"%@${method.path}", self.basePath];

    [#if method.faultsMap?has_content]
    NSMutableDictionary *errorCodes = [[NSMutableDictionary alloc] init];
    NSMutableIndexSet *errorIndexes = [[NSMutableIndexSet alloc] init];
    [#list method.faultsMap?keys as faultKey]
        errorCodes[[NSNumber numberWithInt: ${faultKey}]] = @"${projectPrefix}${method.faultsMap[faultKey].name}";
        [errorIndexes addIndex: ${faultKey}];
    [/#list]
    [/#if]

    // remove format in URL if needed
    if ([requestUrl rangeOfString:@".{format}"].location != NSNotFound) {
        [requestUrl replaceCharactersInRange: [requestUrl rangeOfString:@".{format}"] withString:@".json"];
    }

    [#if method.request??]
    NSString* requestContentType = @"application/json";
    [#else]
    NSString* requestContentType = nil;
    [/#if]

    NSString* responseContentType = @"application/json";

    NSMutableDictionary* queryParams = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* headerParams = [[NSMutableDictionary alloc] init];

    id bodyDictionary = nil;
    [#if method.type = "GET"]
    bodyDictionary = [[NSMutableDictionary alloc] init];
    [#if method.requestParams??]
    [#list method.requestParams as param]
    if(${param.name}) bodyDictionary${"[@"}"${param.name}"] = ${param.name};
    [/#list]
    [/#if]
    [/#if]
    [#if method.request??]
    if(body != nil && [body isKindOfClass:[NSArray class]]){
        NSMutableArray * objs = [[NSMutableArray alloc] init];
        for (id dict in (NSArray*)body) {
            if([dict respondsToSelector:@selector(asDictionary)]) {
                [objs addObject:[(${generatedPrefix}Object*)dict asDictionary]];
            }
            else{
                [objs addObject:dict];
            }
        }
        bodyDictionary = objs;
    }
    else if([body respondsToSelector:@selector(asDictionary)]) {
        bodyDictionary = [(${generatedPrefix}Object*)body asDictionary];
    }
    else if([body isKindOfClass:[NSString class]]) {
        // convert it to a dictionary
        NSError * error;
        NSString * str = (NSString*)body;
        NSDictionary *JSON =
        [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]
        options:NSJSONReadingMutableContainers
        error:&error];
        bodyDictionary = JSON;
    }
    else if([body isKindOfClass: [${generatedPrefix}File class]]) {
        requestContentType = @"form-data";
        bodyDictionary = body;
    }
    else{
        NSLog(@"don't know what to do with %@", body);
    }

    if(body == nil) {
        // error
    }
    [/#if]
    ${generatedPrefix}ApiClient* client = [${generatedPrefix}ApiClient sharedClientFromPool:self.basePath];

    return [client dictionary:requestUrl
    method:@"${method.type}"
    queryParams:queryParams
    body:bodyDictionary
    headerParams:headerParams
     requestContentType:requestContentType
    responseContentType:responseContentType
     responseErrorCodes:[#if method.faultsMap?has_content]errorIndexes[#else]nil[/#if]
    completionBlock:^(NSDictionary *data, NSError *error, NSDictionary *errorData, NSInteger statusCode) {

    if (error) {
        completionBlock(nil, error[#compress]
            [#list method.faults as dummy],nil[/#list]
        [/#compress]);
        return;
    }

    [#if method.faultsMap?has_content]
    if(errorData) {
        NSString *className = errorCodes[[NSNumber numberWithInt:statusCode]];
        id errorObject = [[NSClassFromString(className) alloc] initWithDictionary:errorData];
        [#list method.faults as fault]
            ${projectPrefix}${fault.name} *occured${fault.name} = nil;
        [/#list]
        switch(statusCode) {
            [#list method.faultsMap?keys as faultKey]
            case ${faultKey}:
                occured${method.faultsMap[faultKey].name} = (${projectPrefix}${method.faultsMap[faultKey].name}*)errorObject;
            break;
            [/#list]
        }
        completionBlock(nil, nil[#compress]
    [#list method.faults as fault], occured${fault.name}[/#list]
    [/#compress]);
        return;
    }
    [/#if]

    ${projectPrefix}${method.response.name} *result = nil;

    if (data) {
        result = [[${projectPrefix}${method.response.name} alloc]initWithDictionnary: data];
    }

    completionBlock(result , nil[#compress]
    [#list method.faults as dummy], nil[/#list]
[/#compress]);
    }
    ];
}
[/#list]

@end