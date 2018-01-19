[#ftl]
[#--template for the client-side complex/simple _type interface.--]
// Generated by xsd compiler for ios/objective-c
// DO NOT CHANGE!

#import <Foundation/Foundation.h>
[#if clazz.persistentClass]
#import "${projectPrefix}RLMObject.h"
[#else]
#import "${projectPrefix}Object.h"
[/#if]
#import "${projectPrefix}TimeZoneDate.h"
[#list superClassImports as import]
#import "${import}.h"
[/#list]

[#if clazz.abstract]
// abstract class
[/#if]

[#list fieldClassImports as import]
#import "${import}.h"
[/#list]

/**
 ${clazz.docComment?default("(public class)")?replace("\n", "\n ")?replace("\t", "")}

*/
[#if clazz.superClass??]
    [#assign superClass = "${projectPrefix}${clazz.superClass.name}"]
[#elseif clazz.persistentClass]
    [#assign superClass = "${projectPrefix}RLMObject"]
[#else]
    [#assign superClass = "${projectPrefix}Object"]
[/#if]
@interface ${projectPrefix}${clazz.name} : ${superClass}

[#list clazz.fields as field]
/**
 ${field.docComment?default("(public property)")?replace("\n", "\n ")?replace("\t", "")}
*/
    [#assign forceReadOnly = false]
    [#assign fieldTypePersistent = ""]
    [#if field.type.collection]
        [#assign type = field.type.typeParameters?first]
        [#assign fieldType = "NSMutableArray/*"]
        [#if !type.primitive]
            [#assign fieldType = "${fieldType}${projectPrefix}"]
            [#if clazz.persistentClass][#assign fieldTypePersistent = "RLMArray<${projectPrefix}${type.fullName} *><${projectPrefix}${type.fullName}>"][/#if]
        [#else]
            [#if clazz.persistentClass][#assign fieldTypePersistent = "RLMArray<${type.fullName} *><${type.fullName}>"][/#if]
        [/#if]
        [#assign fieldType = "${fieldType}${type.fullName}*/"]
    [#elseif field.type.enum]
            [#assign fieldType = "${projectPrefix}${field.type.fullName}"]
            [#if clazz.persistentClass] [#assign forceReadOnly = true] [/#if]
    [#elseif field.propertyKindAny]
            [#assign fieldType = "NSMutableArray"]
            [#if clazz.persistentClass][#assign fieldTypePersistent = "RLMArray<Object *><Object>"][/#if]
    [#else]
        [#if field.type.primitive && field.type.name != "DATE"]
            [#if field.type.name == "BOOL"]
                [#assign fieldType = "${field.type.fullName}/*bool*/"]
                [#if clazz.persistentClass][#assign fieldTypePersistent = "${field.type.fullName}<RLMBool>"][/#if]
            [#elseif field.type.name == "INTEGER"]
                [#assign fieldType = "${field.type.fullName}/*int*/"]
                [#if clazz.persistentClass][#assign fieldTypePersistent = "${field.type.fullName}<RLMInt>"][/#if]
            [#elseif field.type.name == "FLOAT"]
                [#assign fieldType = "${field.type.fullName}/*float*/"]
                [#if clazz.persistentClass][#assign fieldTypePersistent = "${field.type.fullName}<RLMFloat>"][/#if]
            [#elseif field.type.name == "DOUBLE"]
                [#assign fieldType = "${field.type.fullName}/*double*/"]
                [#if clazz.persistentClass][#assign fieldTypePersistent = "${field.type.fullName}<RLMDouble>"][/#if]
            [#elseif field.type.name == "LONG"]
                [#assign fieldType = "${field.type.fullName}/*long*/"]
            [#else]
                [#assign fieldType = "${field.type.fullName}"]
            [/#if]
        [#else]
                [#assign fieldType = "${projectPrefix}${field.type.fullName}"]
        [/#if]
    [/#if]
@property (nonatomic, [#if field.fixedValue || forceReadOnly]readonly[#else]${field.type.wrapper.qualifier.qualifierName}[/#if]) [#if fieldTypePersistent?has_content]${fieldTypePersistent}[#else]${fieldType}[/#if] [#if field.type.wrapper.pointer]*[/#if]${field.name};

[/#list]
[#assign fieldIndex = 0]
[#assign values = ""]
[#list clazz.fields as field]
    [#if !field.value??]
        [#if fieldIndex == 0]
            [#assign values = "${values}${field.name?cap_first}"]
        [#else]
            [#assign values = "${values} ${field.name}"]
        [/#if]
        [#assign values = "${values}: ("]
        [#if field.type.collection]
            [#assign typeParameter = field.type.typeParameters?first]
            [#if typeParameter.primitive]
                [#assign typeParameterName = "${field.type.typeParameters[0].fullName}"]
            [#else]
                [#assign typeParameterName = "${projectPrefix}${field.type.typeParameters[0].fullName}"]
            [/#if]
            [#assign values = "${values}NSMutableArray/*${typeParameterName}*/"]
        [#elseif field.type.enum]
            [#assign values = "${values}${projectPrefix}${field.type.fullName}"]
        [#elseif field.propertyKindAny]
            [#assign values = "${values}NSMutableArray"]
        [#elseif field.type.primitive && field.type.name != "DATE"]
            [#assign values = "${values}${field.type.fullName}"]
        [#else]
            [#assign values = "${values}${projectPrefix}${field.type.fullName}"]
        [/#if]
        [#if field.type.wrapper.pointer]
            [#assign values = "${values}*"]
        [/#if]
        [#assign values = "${values}) ${field.name}Param"]
        [#assign fieldIndex = fieldIndex + 1]
    [/#if]
[/#list]
- (id) initWithValues${values};

@end
