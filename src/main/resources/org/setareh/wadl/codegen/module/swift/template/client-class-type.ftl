[#ftl]
[#--template for the client class.--]
// Generated by xsd compiler for swift/ios
// DO NOT CHANGE!

class ${projectPrefix}${clazz.name}[#if clazz.superClass??]: ${projectPrefix}${clazz.superClass.name}[/#if] {

    [#list clazz.fields as field]
    [#compress]
    [#if field.value??]
        [#if field.type.enum]
            [#assign value = "${field.type.name}.${field.value}"]
        [#elseif field.type.wrapper.type == "String"]
            [#assign value = "\"${field.value}\""]
        [#elseif field.type.primitive]
            [#assign value = "${field.value}"]
        [#else]
            [#assign value = "null /* TODO not implemented ?*/"]
        [/#if]
    [/#if]
    [#if field.type.collection]
        [#assign typeParameter = field.type.typeParameters?first]
        [#if typeParameter.primitive]
            [#assign typeParameterName = "${field.type.typeParameters[0].fullName}"]
        [#else]
            [#assign typeParameterName = "${projectPrefix}${field.type.typeParameters[0].fullName}"]
        [/#if]
        [#assign fullName = "[${typeParameterName}]"]
    [#elseif field.type.enum]
        [#assign fullName = "${projectPrefix}${field.type.fullName}"]
    [#elseif field.type.primitive]
        [#assign fullName = "${field.type.fullName}"]
    [#else]
        [#assign fullName = "${projectPrefix}${field.type.fullName}"]
    [/#if]
	[/#compress]
	[#if field.fixedValue]let[#else]var[/#if] ${field.name} [#if field.value??]= ${value}[#else]: ${fullName}![/#if]

    [/#list]

    [#if clazz.superClass??]override [/#if]init() {

    }

    [#-- need managesuperClass : too complicated
    [#assign fieldIndex = 0]
    [#assign values = ""]
    [#list clazz.fields as field]
        [#if field.type.collection]
            [#assign typeParameter = field.type.typeParameters?first]
            [#if typeParameter.primitive]
                [#assign typeParameterName = "${field.type.typeParameters[0].fullName}"]
            [#else]
                [#assign typeParameterName = "${projectPrefix}${field.type.typeParameters[0].fullName}"]
            [/#if]
            [#assign fullName = "Array<${typeParameterName}>"]
        [#elseif field.type.enum]
            [#assign fullName = "${projectPrefix}${field.type.fullName}"]
        [#elseif field.type.primitive]
            [#assign fullName = "${field.type.fullName}"]
        [#else]
            [#assign fullName = "${projectPrefix}${field.type.fullName}"]
        [/#if]
        [#if !field.value??]
            [#if fieldIndex == 0]
                [#assign values = "${field.name}: ${fullName} "]
            [#else]
                [#assign values = "${values}, ${field.name}: ${fullName} "]
            [/#if]
            [#assign fieldIndex = fieldIndex + 1]
        [/#if]

    [/#list]
    init(${values}) {
    [#list clazz.fields as field]
        [#if !field.value??]
        self.${field.name} = ${field.name}
        [/#if]
    [/#list]
    }
    --]

[#if clazz.superClass??]override [/#if]func initWithDictionnary(dict: Dictionary<String,Any>) -> ${projectPrefix}${clazz.name}
{
[#if clazz.superClass??]super.initWithDictionnary(dict)[/#if]

[#list clazz.fields as field]
[#if !field.fixedValue]
if (dict["${field.name}"] != nil)
{
   [#if field.type.enum]
   self.${field.name} = dict["${field.initialName}"] as? ${projectPrefix}${field.type.fullName}
   [#elseif field.type.collection || field.type.array]

       [#assign typeParameter = field.type.typeParameters?first]

       [#if typeParameter.enum]
       var ${field.name}_dict:[${projectPrefix}${typeParameter.fullName}] = dict["${field.initialName}"] as [${projectPrefix}${typeParameter.fullName}]
       [#elseif typeParameter.primitive]
       var ${field.name}_dict:[${typeParameter.fullName}] = dict["${field.initialName}"] as [${typeParameter.fullName}]
       [#else]
       var ${field.name}_dict:[Dictionary<String,Any>] = dict["${field.initialName}"] as [Dictionary<String,Any>]
       [/#if]

   var ${field.name}Array = [[#if typeParameter.primitive]${typeParameter.fullName}[#else]${projectPrefix}${typeParameter.fullName}[/#if]]()

   if(${field.name}_dict.count > 0) {

       [#if typeParameter.enum]
       for (String dictValue in ${field.name}_dict) {
       var d:${projectPrefix}${typeParameter.fullName} = dictValue as? ${projectPrefix}${typeParameter.fullName}
       [#elseif typeParameter.primitive]
           [#if field.type.wrapper == "NSDATE"]
           for dictValue in ${field.name}_dict {
           var d:${typeParameter.fullName} = [${projectPrefix}DateFormatterUtils convertToDate:dictValue]
           [#else]
           for dictValue in ${field.name}_dict {
           var d:${typeParameter.fullName} = dictValue
           [/#if]
       [#else]
       for dict in ${field.name}_dict {
       var d:${projectPrefix}${typeParameter.fullName} = ${projectPrefix}${typeParameter.fullName}().initWithDictionnary(dict)
       [/#if]

   ${field.name}Array.append(d)
   }
   self.${field.name} = ${field.name}Array
   }
   [#elseif field.type.primitive]
       [#if field.type.wrapper == "NSDATE"]
       self.${field.name} = [${projectPrefix}DateFormatterUtils convertToDate:dict["${field.initialName}"]]
       [#else]
       self.${field.name} = dict["${field.initialName}"] as[#if field.type.wrapper.type != "Bool" && !field.value??]?[/#if] ${field.type.wrapper.type}
       [/#if]
   [#else]
   var ${field.name}_dict:Dictionary<String,Any> = dict["${field.initialName}"] as Dictionary
   if(${field.name}_dict.isEmpty) {
   self.${field.name} = ${projectPrefix}${field.type.fullName}().initWithDictionnary(${field.name}_dict)
   }
   [/#if]
}
[/#if]
[/#list]
return self
}

[#if clazz.superClass??]override [/#if]func asDictionary() ->  Dictionary<String,Any>{
var dict:Dictionary<String,Any> [#if clazz.superClass??]= super.asDictionary()[#else]= Dictionary<String,Any>()[/#if]

[#list clazz.fields as field]

    [#if field.type.enum]
    if(self.${field.name} != nil) {
    dict["${field.initialName}"] = self.${field.name}
    }
    [#elseif field.type.primitive || field.propertyKindAny]
        [#if field.type.wrapper.pointer]if(self.${field.name} != nil) {[/#if]
        [#if field.type.wrapper == "NSDATE"]
        dict["${field.initialName}"] = [${projectPrefix}DateFormatterUtils formatWithDate:self.${field.name}]
        [#else]
        dict["${field.initialName}"] = self.${field.name}
        [/#if]
        [#if field.type.wrapper.pointer]}[/#if]
    [#elseif field.type.array || field.type.collection]
        [#assign typeParameter = field.type.typeParameters?first]
    if(self.${field.name} != nil){
        [#if typeParameter.enum]
        var array = [${projectPrefix}${typeParameter.fullName}]()
        for ${field.name}Element in self.${field.name} {
        [array addObject:${field.name}Element
        [#elseif typeParameter.primitive]
        var array = [${typeParameter.fullName}]()
        for ${field.name}Element in self.${field.name} {
            [#if typeParameter.wrapper == "NSDATE"]
            array.append(${projectPrefix}DateFormatterUtils.formatWithdate(${field.name}Element))
            [#else]
            array.append(${field.name}Element)
            [/#if]
        [#else]
        var array = [Dictionary<String,Any>]()
        for ${field.name}Element in self.${field.name} {
        array.append(${field.name}Element.asDictionary())
        [/#if]
    }
    dict["${field.initialName}"] = array
    }
    [#else]
    if(self.${field.name} != nil) {
    dict["${field.initialName}"] = self.${field.name}.asDictionary()
    }
    [/#if]
[/#list]
return dict
}

}