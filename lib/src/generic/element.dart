import 'package:analyzer/dart/element/element.dart';

import 'paths.dart';

extension UriExtension on Element {
  String get path {
    String childPath = displayName;
    var parent = enclosingElement;
    if (parent != null) {
      String parentPath = parent.path;
      if (parentPath.isEmpty && childPath.isEmpty) {
        return '';
      } else if (parentPath.isEmpty && childPath.isNotEmpty) {
        return childPath;
      } else if (parentPath.isNotEmpty && childPath.isEmpty) {
        return parentPath;
      } else if (parentPath.isNotEmpty && childPath.isNotEmpty) {
        return '$parentPath.$childPath';
      }
    }
    return childPath;
  }
}

/// An [ElementVisitor] for finding the first element with a matching [DartMemberPath]
class ElementFinder implements ElementVisitor {
  final String memberPathToFind;

  Element? foundElement;

  ElementFinder(DartMemberPath dartMemberPath)
      : memberPathToFind = dartMemberPath.toString();

  @override
  visitClassElement(ClassElement element) {
    checkElementRecursively(element);
  }

  @override
  visitCompilationUnitElement(CompilationUnitElement element) {
    checkElementRecursively(element);
  }

  @override
  visitConstructorElement(ConstructorElement element) {
    checkElementRecursively(element);
  }

  @override
  visitExportElement(ExportElement element) {
    checkElementRecursively(element);
  }

  @override
  visitExtensionElement(ExtensionElement element) {
    checkElementRecursively(element);
  }

  @override
  visitFieldElement(FieldElement element) {
    checkElementRecursively(element);
  }

  @override
  visitFieldFormalParameterElement(FieldFormalParameterElement element) {
    checkElementRecursively(element);
  }

  @override
  visitFunctionElement(FunctionElement element) {
    checkElementRecursively(element);
  }

  @override
  visitGenericFunctionTypeElement(GenericFunctionTypeElement element) {
    checkElementRecursively(element);
  }

  @override
  visitImportElement(ImportElement element) {
    checkElementRecursively(element);
  }

  @override
  visitLabelElement(LabelElement element) {
    checkElementRecursively(element);
  }

  @override
  visitLibraryElement(LibraryElement element) {
    checkElementRecursively(element);
  }

  @override
  visitLocalVariableElement(LocalVariableElement element) {
    checkElementRecursively(element);
  }

  @override
  visitMethodElement(MethodElement element) {
    checkElementRecursively(element);
  }

  @override
  visitMultiplyDefinedElement(MultiplyDefinedElement element) {
    checkElementRecursively(element);
  }

  @override
  visitParameterElement(ParameterElement element) {
    checkElementRecursively(element);
  }

  @override
  visitPrefixElement(PrefixElement element) {
    checkElementRecursively(element);
  }

  @override
  visitPropertyAccessorElement(PropertyAccessorElement element) {
    checkElementRecursively(element);
  }

  @override
  visitTopLevelVariableElement(TopLevelVariableElement element) {
    checkElementRecursively(element);
  }

  @override
  visitTypeAliasElement(TypeAliasElement element) {
    checkElementRecursively(element);
  }

  @override
  visitTypeParameterElement(TypeParameterElement element) {
    checkElementRecursively(element);
  }

  @override
  visitSuperFormalParameterElement(SuperFormalParameterElement element) {
    checkElementRecursively(element);
  }

  checkElementRecursively(Element element) {
    if (foundElement == null) {
      var memberPath = element.path;
      if (memberPath == memberPathToFind) {
        foundElement = element;
      } else if (memberPathToFind.startsWith(memberPath)) {
        //search recursively;
        element.visitChildren(this);
      }
    }
  }

  @override
  visitAugmentationImportElement(AugmentationImportElement element) {
    throw UnimplementedError();
  }

  @override
  visitLibraryAugmentationElement(LibraryAugmentationElement element) {
    throw UnimplementedError();
  }

// TODO extension element???
// String _memberPath(Element element, List<String> path) {
//   String pathSegment = element.displayName;
//   if (pathSegment.trim().isNotEmpty) path.insert(0, pathSegment);
//   var parent = element.enclosingElement;
//   if (parent != null) _memberPath(parent, path);
//   return path.join('.');
// }
}

/// An [ElementVisitor] for finding all [DartCodePath]s
class DartCodePathFinder implements ElementVisitor {
  final Set<DartCodePath> foundPaths = {};
  final DartFilePath dartFilePath;

  DartCodePathFinder(this.dartFilePath);

  @override
  visitClassElement(ClassElement element) {
    checkElementRecursively(element);
  }

  @override
  visitCompilationUnitElement(CompilationUnitElement element) {
    checkElementRecursively(element);
  }

  @override
  visitConstructorElement(ConstructorElement element) {
    checkElementRecursively(element);
  }

  @override
  visitExportElement(ExportElement element) {
    checkElementRecursively(element);
  }

  @override
  visitExtensionElement(ExtensionElement element) {
    checkElementRecursively(element);
  }

  @override
  visitFieldElement(FieldElement element) {
    checkElementRecursively(element);
  }

  @override
  visitFieldFormalParameterElement(FieldFormalParameterElement element) {
    checkElementRecursively(element);
  }

  @override
  visitFunctionElement(FunctionElement element) {
    checkElementRecursively(element);
  }

  @override
  visitGenericFunctionTypeElement(GenericFunctionTypeElement element) {
    checkElementRecursively(element);
  }

  @override
  visitImportElement(ImportElement element) {
    checkElementRecursively(element);
  }

  @override
  visitLabelElement(LabelElement element) {
    checkElementRecursively(element);
  }

  @override
  visitLibraryElement(LibraryElement element) {
    checkElementRecursively(element);
  }

  @override
  visitLocalVariableElement(LocalVariableElement element) {
    checkElementRecursively(element);
  }

  @override
  visitMethodElement(MethodElement element) {
    checkElementRecursively(element);
  }

  @override
  visitMultiplyDefinedElement(MultiplyDefinedElement element) {
    checkElementRecursively(element);
  }

  @override
  visitParameterElement(ParameterElement element) {
    checkElementRecursively(element);
  }

  @override
  visitPrefixElement(PrefixElement element) {
    checkElementRecursively(element);
  }

  @override
  visitPropertyAccessorElement(PropertyAccessorElement element) {
    checkElementRecursively(element);
  }

  @override
  visitTopLevelVariableElement(TopLevelVariableElement element) {
    checkElementRecursively(element);
  }

  @override
  visitTypeAliasElement(TypeAliasElement element) {
    checkElementRecursively(element);
  }

  @override
  visitTypeParameterElement(TypeParameterElement element) {
    checkElementRecursively(element);
  }

  checkElementRecursively(Element element) {
    if (element is! LibraryElement && element.path.isNotEmpty) {
      try {
        DartCodePath path = DartCodePath('$dartFilePath|${element.path}');
        foundPaths.add(path);
      } catch (e) {
        // failed try next...
      }
    }
    //search recursively;
    element.visitChildren(this);
  }

  @override
  visitSuperFormalParameterElement(SuperFormalParameterElement element) {
    throw UnimplementedError();
  }

  @override
  visitAugmentationImportElement(AugmentationImportElement element) {
    throw UnimplementedError();
  }

  @override
  visitLibraryAugmentationElement(LibraryAugmentationElement element) {
    throw UnimplementedError();
  }
}
