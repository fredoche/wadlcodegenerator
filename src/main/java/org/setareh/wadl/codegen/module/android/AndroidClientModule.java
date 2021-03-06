package org.setareh.wadl.codegen.module.android;

import freemarker.template.SimpleHash;
import org.setareh.wadl.codegen.model.*;
import org.setareh.wadl.codegen.module.*;
import org.setareh.wadl.codegen.utils.ClassNameUtil;

import javax.xml.datatype.XMLGregorianCalendar;
import java.net.URL;
import java.util.*;

/**
 * @author bulldog
 */
public class AndroidClientModule extends AbstractClientModule {

    private static final String JAVA_DEFAULT_PACKAGE_NAME = "java.lang";
    private static final String SOURCE_FOLDER = "src/main/java";

    private Map<String, String> typeMapping = new HashMap<String, String>();

    // references to templates
    private URL classTemplate;
    private URL enumTemplate;
    private URL apiExceptionTemplate;
    private URL apiConfigTemplate;
    private URL apiComputedHttpHeaderTemplate;
    private URL apiInvokerTemplate;
    private URL apiJSonUtilTemplate;
    private URL apiServiceTemplate;
    private URL projectModelTemplate;

    @Override
    public ModuleName getName() {
        return ModuleName.ANDROID;
    }

    @Override
    public void init() throws ModuleException {
        //info("AndroidClientModule loading templates ...");
        loadTemplates();

        // some custom type mappings
        // android does not fully support these data types yet
        typeMapping.put(XMLGregorianCalendar.class.getName(),
                "org.joda.time.DateTime");
    }

    private void loadTemplates() throws ModuleException {
        classTemplate = getTemplateURL("client-class-type.ftl");
        enumTemplate = getTemplateURL("client-enum-type.ftl");
        apiExceptionTemplate = getTemplateURL("client-services-api-exception.ftl");
        apiConfigTemplate = getTemplateURL("client-services-api-config.ftl");
        apiComputedHttpHeaderTemplate = getTemplateURL("client-services-api-computed-http-header.ftl");
        apiInvokerTemplate = getTemplateURL("client-services-api-invoker.ftl");
        apiJSonUtilTemplate = getTemplateURL("client-services-api-jsonutil.ftl");
        apiServiceTemplate = getTemplateURL("client-services-api-service.ftl");
        projectModelTemplate = getTemplateURL("client-pom.ftl");
    }

    @Override
    public Set<FileInfo> generate(CGModel cgModel, CGConfig config) throws ModuleException {
        // freemarker datamodel
        SimpleHash fmModel = this.getFreemarkerModel();

        // container for target codes
        Set<FileInfo> targetFileSet = new HashSet<FileInfo>();

        //info("Generating the client classes...");

        // adjust package name of nested class
        adjustPackageNameOfNestClass(cgModel.getClasses());

        fmModel.put("config", config);

        // generate classes
        //info("Generating classes ...");
        for (ClassInfo classInfo : cgModel.getClasses()) {
            this.convertFieldsType(classInfo);
            fmModel.put("clazz", classInfo);
            fmModel.put("imports", this.getClassImports(classInfo));
            String relativePath = ClassNameUtil.packageNameToPath(classInfo.getPackageName());
            FileInfo classFile = this.generateFile(classTemplate, fmModel, classInfo.getName(), "java", relativePath, SOURCE_FOLDER);
            targetFileSet.add(classFile);
        }

        // generate enums
        //info("Generating enums ...");
        for (EnumInfo enumInfo : cgModel.getEnums()) {
            fmModel.put("enum", enumInfo);
            String relativePath = ClassNameUtil.packageNameToPath(enumInfo.getPackageName());
            FileInfo classFile = this.generateFile(enumTemplate, fmModel, enumInfo.getName(), "java", relativePath, SOURCE_FOLDER);
            targetFileSet.add(classFile);
        }

        return targetFileSet;
    }

    @Override
    public Set<FileInfo> generate(CGServices cgServices, CGConfig cgConfig) throws ModuleException {
        Set<FileInfo> targetFileSet = new HashSet<>();

        // generation des classes utilitaires

        String utilityPackageName = cgConfig.packageName + ".client";

        SimpleHash fmModel = this.getFreemarkerModel();
        fmModel.put("packageName", utilityPackageName);

        FileInfo apiExceptionFile = this.generateFile(apiExceptionTemplate, fmModel, "ApiException", "java", ClassNameUtil.packageNameToPath(utilityPackageName), SOURCE_FOLDER);
        targetFileSet.add(apiExceptionFile);

        FileInfo apiConfigFile = this.generateFile(apiConfigTemplate, fmModel, "ApiConfig", "java", ClassNameUtil.packageNameToPath(utilityPackageName), SOURCE_FOLDER);
        targetFileSet.add(apiConfigFile);

        FileInfo apiComputedHttpHeader = this.generateFile(apiComputedHttpHeaderTemplate, fmModel, "ComputedHttpHeaderValue", "java", ClassNameUtil.packageNameToPath(utilityPackageName), SOURCE_FOLDER);
        targetFileSet.add(apiComputedHttpHeader);

        FileInfo apiInvokerFile = this.generateFile(apiInvokerTemplate, fmModel, "ApiInvoker", "java", ClassNameUtil.packageNameToPath(utilityPackageName), SOURCE_FOLDER);
        targetFileSet.add(apiInvokerFile);

        FileInfo apiJSonUtilFile = this.generateFile(apiJSonUtilTemplate, fmModel, "JsonUtil", "java", ClassNameUtil.packageNameToPath(utilityPackageName), SOURCE_FOLDER);
        targetFileSet.add(apiJSonUtilFile);

        // generation des services

        String servicePackageName = cgConfig.packageName + ".api";

        for (CGService cgService : cgServices.getServices()) {
            fmModel = this.getFreemarkerModel();
            fmModel.put("packageName", servicePackageName);
            fmModel.put("utilityPackageName", utilityPackageName);
            fmModel.put("imports", getImports(cgService.getMethods()));
            fmModel.put("faults", getFaults(cgService.getMethods()));
            fmModel.put("className", cgService.getName());
            fmModel.put("methods", cgService.getMethods());
            FileInfo apiServiceFile = this.generateFile(apiServiceTemplate, fmModel, cgService.getName() + "Api", "java", ClassNameUtil.packageNameToPath(servicePackageName), SOURCE_FOLDER);
            targetFileSet.add(apiServiceFile);
        }

        return targetFileSet;
    }

    private Set<ClassInfo> getFaults(List<CGMethod> methods) {
        final HashSet<ClassInfo> classes = new HashSet<>();
        for (CGMethod method : methods) {
            classes.addAll(method.getFaults());
        }
        return classes;
    }

    @Override
    public Set<FileInfo> generateProjectModel(CGConfig cgConfig) throws ModuleException {
        Set<FileInfo> targetFileSet = new HashSet<FileInfo>();

        SimpleHash fmModel = this.getFreemarkerModel();
        fmModel.put("groupId", cgConfig.packageName);
        FileInfo apiJSonUtilFile = this.generateFile(projectModelTemplate, fmModel, "pom", "xml", "", "");
        targetFileSet.add(apiJSonUtilFile);

        return targetFileSet;
    }

    private Set<String> getImports(List<CGMethod> methods) {
        Set<String> imports = new HashSet<>();
        for (CGMethod method : methods) {
            if (method.getRequest() != null) {
                imports.add(method.getRequest().getPackageName() + "." + method.getRequest().getName());
            }
            if (method.getResponse() != null) {
                imports.add(method.getResponse().getPackageName() + "." + method.getResponse().getName());
            }
            for (ClassInfo classInfo : method.getFaults()) {
                imports.add(classInfo.getPackageName() + "." + classInfo.getName());
            }
            for (CGParam cgParam : method.getRequestParams()) {
                final ClassInfo classInfo = cgParam.getClassInfo();
                final String packageName = classInfo.getPackageName();
                if(!packageName.startsWith("org.w3")) {
                    imports.add(packageName + "." + classInfo.getName());
                }
            }
            for (CGParam cgParam : method.getTemplateParams()) {
                final ClassInfo classInfo = cgParam.getClassInfo();
                final String packageName = classInfo.getPackageName();
                if(!packageName.startsWith("org.w3")) {
                    imports.add(packageName + "." + classInfo.getName());
                }
            }
        }

        return imports;
    }

    /**
     * Check and convert a type
     *
     * @param type, TypeInfo instance
     */
    @Override
    protected void convertType(TypeInfo type) {
        String targetTypeFullName = typeMapping.get(type.getFullName());
        if (targetTypeFullName != null) {
            type.setFullName(targetTypeFullName);
            type.setName(ClassNameUtil.stripQualifier(targetTypeFullName));
        } else {
            if (type.isCollection()) { // special handling for collection type
                for (String oldTypeFullName : typeMapping.keySet()) {
                    if (type.getFullName().indexOf(oldTypeFullName) > 0) { // including type parameter?
                        String newTypeFullName = typeMapping.get(oldTypeFullName);
                        String newFullName = type.getFullName().replace(oldTypeFullName, newTypeFullName);
                        String oldSimpleName = ClassNameUtil.stripQualifier(oldTypeFullName);
                        String newSimpleName = ClassNameUtil.stripQualifier(newTypeFullName);
                        String newName = type.getName().replace(oldSimpleName, newSimpleName);
                        type.setFullName(newFullName);
                        type.setName(newName);
                    }
                }
            }
        }
    }


    // for java implementation, we need to change nested class into package-member class,
    // so package name should be adjusted accordingly
    private void adjustPackageNameOfNestClass(Collection<ClassInfo> classes) {
        for (ClassInfo classInfo : classes) {
            // adjust class
            if (classInfo.isNestClass()) {
                String pkgName = classInfo.getPackageName().toLowerCase();
                classInfo.setPackageName(pkgName);
                classInfo.setFullName(pkgName + "." + classInfo.getName());
            }
            // adjust fields
            for (FieldInfo fieldInfo : classInfo.getFields()) {
                TypeInfo attrType = fieldInfo.getType();

                // no need to handle primitive type
                if (attrType.isPrimitive())
                    continue;

                // handle array
                if (attrType.isArray()) {
                    // T of T[]
                    TypeInfo elementType = attrType.getElementType();
                    // no need to handle primitive type
                    if (elementType.isPrimitive()) {
                        continue;
                    }
                    if (elementType.isNestClass()) {
                        String elementTypePackageName = ClassNameUtil
                                .getPackageName(elementType.getFullName());
                        elementTypePackageName = elementTypePackageName.toLowerCase();
                        elementType.setFullName(elementTypePackageName + "." + elementType.getName());
                    }
                    continue;
                }

                if (attrType.isNestClass()) {
                    String attrTypePackageName = ClassNameUtil.getPackageName(attrType.getFullName());
                    attrTypePackageName = attrTypePackageName.toLowerCase();
                    attrType.setFullName(attrTypePackageName + "." + attrType.getName());
                }

                // has type parameters?
                for (TypeInfo paramType : attrType.getTypeParameters()) {
                    if (paramType.isNestClass()) {
                        String paramTypePackageName = ClassNameUtil
                                .getPackageName(paramType.getFullName());
                        paramTypePackageName = paramTypePackageName.toLowerCase();
                        paramType.setFullName(paramTypePackageName + "." + paramType.getName());
                    }
                }
            }
        }
    }

    /**
     * helper to find out all classes that should be imported by a class
     *
     * @param clazz , ClassInfo instance
     * @return a set of class names that should be imported
     */
    private Set<String> getClassImports(ClassInfo clazz) {
        Set<String> imports = new HashSet<String>();
        String clazzPackageName = clazz.getPackageName();

        // extends super class?
        if (clazz.getSuperClass() != null) {
            ClassInfo superClass = clazz.getSuperClass();
            String superClassTypePackageName = ClassNameUtil
                    .getPackageName(superClass.getFullName());
            if (needImport(clazzPackageName, superClassTypePackageName)) {
                imports.add(ClassNameUtil.erase(superClass.getFullName()));
            }

        }

        // import field type
        for (FieldInfo field : clazz.getFields()) {
            TypeInfo attrType = field.getType();
            String attrTypePackageName = ClassNameUtil.getPackageName(attrType.getFullName());

            // no import for primitive type
            if (attrType.isPrimitive())
                continue;

            // import component type of array
            if (attrType.isArray()) {
                // T of T[]
                TypeInfo elementType = attrType.getElementType();
                // no import for primitive type
                if (elementType.isPrimitive()) {
                    continue;
                }
                String elementTypePackageName = ClassNameUtil
                        .getPackageName(elementType.getFullName());
                if (needImport(clazzPackageName, elementTypePackageName)) {
                    imports.add(ClassNameUtil.erase(elementType.getFullName()));
                }
                continue;
            }

            if (needImport(clazzPackageName, attrTypePackageName)) {
                // erase type parameters before import
                imports.add(ClassNameUtil.erase(attrType.getFullName()));
            }
            // has type parameters?
            for (TypeInfo paramType : attrType.getTypeParameters()) {
                String paramTypePackageName = ClassNameUtil
                        .getPackageName(paramType.getFullName());
                if (needImport(clazzPackageName, paramTypePackageName)) {
                    // erase type parameters before import
                    imports.add(ClassNameUtil.erase(paramType.getFullName()));
                }
            }
        }

        return imports;
    }



    private boolean needImport(String current, String target) {
        if (!target.equals(current) && !target.startsWith(JAVA_DEFAULT_PACKAGE_NAME)) {
            return true;
        }
        return false;
    }





    @Override
    protected Set<String> getReservedWords() {
        Set<String> reservedWord = new HashSet<String>();
        reservedWord.add("abstract");
        reservedWord.add("assert");
        reservedWord.add("boolean");
        reservedWord.add("break");
        reservedWord.add("byte");
        reservedWord.add("case");
        reservedWord.add("catch");
        reservedWord.add("char");
        reservedWord.add("class");
        reservedWord.add("const");
        reservedWord.add("continue");
        reservedWord.add("default");
        reservedWord.add("do");
        reservedWord.add("double");
        reservedWord.add("else");
        reservedWord.add("enum");
        reservedWord.add("extends");
        reservedWord.add("final");
        reservedWord.add("finally");
        reservedWord.add("float");
        reservedWord.add("for");
        reservedWord.add("goto");
        reservedWord.add("if");
        reservedWord.add("implements");
        reservedWord.add("import");
        reservedWord.add("instanceof");
        reservedWord.add("int");
        reservedWord.add("interface");
        reservedWord.add("long");
        reservedWord.add("native");
        reservedWord.add("new");
        reservedWord.add("package");
        reservedWord.add("private");
        reservedWord.add("protected");
        reservedWord.add("public");
        reservedWord.add("return");
        reservedWord.add("short");
        reservedWord.add("static");
        reservedWord.add("strictfp");
        reservedWord.add("super");
        reservedWord.add("switch");
        reservedWord.add("synchronized");
        reservedWord.add("this");
        reservedWord.add("throw");
        reservedWord.add("throws");
        reservedWord.add("transient");
        reservedWord.add("try");
        reservedWord.add("void");
        reservedWord.add("volatile");
        reservedWord.add("while");
        return reservedWord;
    }

    @Override
    protected Map<String, Wrapper> getWrappers() {
        Map<String, Wrapper> wrappers = new HashMap<String, Wrapper>();

        wrappers.put(Type.DATE, AndroidWrapper.DATETIME);

        return wrappers;
    }

}
