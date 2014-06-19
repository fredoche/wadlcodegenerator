[#ftl]
#import <Foundation/Foundation.h>
[#list imports as import]
#import "${import}"
[/#list]


@interface ${className}Api: NSObject

-(void) addHeader:(NSString*)value forKey:(NSString*)key;
-(unsigned long) requestQueueSize;
- (void)setAuthenticationLogin:(NSString *)login andPassword:(NSString *)password;
+(${className}Api*) sharedApiWithBasePath:(NSString *) basePath;
-(void) setBasePath:(NSString*)basePath;

[#list methods as method]
-(NSNumber*) ${method.name}With[#if method.request??]CompletionBlock:(${projectPrefix}${method.request.name}*) body
[/#if][#if method.requestParams??][#list method.requestParams as param]param${param.name}: (NSString *) ${param.name} [/#list][/#if]completionHandler: (void (^)(${projectPrefix}${method.response.name}* output, NSError* error))completionBlock;
[/#list]

@end