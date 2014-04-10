library angular.core_dynamic;

import 'dart:mirrors';
import 'package:angular/core/annotation.dart';
import 'package:angular/core/registry.dart';

export 'package:angular/core/registry.dart' show
    MetadataExtractor;

var _fieldMetadataCache = new Map<Type, Map<String, AttrFieldAnnotation>>();

class DynamicMetadataExtractor implements MetadataExtractor {
  final _fieldAnnotations = [
        reflectType(NgAttr),
        reflectType(NgOneWay),
        reflectType(NgOneWayOneTime),
        reflectType(NgTwoWay),
        reflectType(NgCallback)
  ];

  Iterable call(Type type) {
    if (reflectType(type) is TypedefMirror) return [];
    ClassMirror cm = reflectClass(type);
    if(cm.simpleName == new Symbol("Sub"))
      print(cm);

    var metadata = reflectClass(type).metadata;
    if (metadata == null) {
      metadata = [];
    } else {
      metadata =  metadata.map((InstanceMirror im) {
        map(type, im.reflectee);
      });
    }
    return metadata;
  }

  Map<String, AttrFieldAnnotation> _extractMappingsFromSuperTypes(ClassMirror cm) {
    var fields = <String, AttrFieldAnnotation>{};
    if(cm.superclass != null) {
      fields = _extractMappingsFromSuperTypes(cm.superclass);
    } else {
      fields = {};
    }
    Map<Symbol, DeclarationMirror> declarations = cm.declarations;
    declarations.forEach((symbol, dm) {
      if(dm is VariableMirror ||
          dm is MethodMirror && (dm.isGetter || dm.isSetter)) {
        var fieldName = MirrorSystem.getName(symbol);
        if (dm is MethodMirror && dm.isSetter) {
          // Remove "=" from the end of the setter.
          fieldName = fieldName.substring(0, fieldName.length - 1);
        }
        dm.metadata.forEach((InstanceMirror meta) {
          if (_fieldAnnotations.contains(meta.type)) {
            if (fields.containsKey(fieldName)) {
              throw 'Attribute annotation for $fieldName is defined more '
                'than once in ${cm.reflectedType}';
            }
            fields[fieldName] = meta.reflectee as AttrFieldAnnotation;
          }
        });
      }
    });
    return fields;
  }

  map(Type type, obj) {
    if (obj is NgAnnotation) {
      return mapDirectiveAnnotation(type, obj);
    } else {
      return obj;
    }
  }

  Map _mergeMaps(Map p, Map q) {
    if (p == null && q == null )
      return null;
    else if (p == null)
      return q;
    else if (q == null)
      return p;
    return {}..addAll(p)..addAll(q);
  }

  NgAnnotation mapDirectiveAnnotation(Type type, NgAnnotation annotation) {
    var match;
    var fieldMetadata = fieldMetadataExtractor(type);
    if (fieldMetadata.isNotEmpty) {
      var newMap = annotation.map == null ? {} : new Map.from(annotation.map);
      fieldMetadata.forEach((String fieldName, AttrFieldAnnotation ann) {
        var attrName = ann.attrName;
        if (newMap.containsKey(attrName)) {
          throw 'Mapping for attribute $attrName is already defined (while '
          'processing annottation for field $fieldName of $type)';
        }
        newMap[attrName] = '${ann.mappingSpec}$fieldName';
      });
      annotation = annotation.cloneWithNewMap(newMap);
    }
    return annotation;
  }


  Map<String, AttrFieldAnnotation> fieldMetadataExtractor(Type type) =>
      _fieldMetadataCache.putIfAbsent(type, () => _fieldMetadataExtractor(type));

  Map<String, AttrFieldAnnotation> _fieldMetadataExtractor(Type type) {
    ClassMirror cm = reflectType(type);
    final fields = <String, AttrFieldAnnotation>{};
    cm.declarations.forEach((Symbol name, DeclarationMirror decl) {
      if (decl is VariableMirror ||
      decl is MethodMirror && (decl.isGetter || decl.isSetter)) {
        var fieldName = MirrorSystem.getName(name);
        if (decl is MethodMirror && decl.isSetter) {
          // Remove "=" from the end of the setter.
          fieldName = fieldName.substring(0, fieldName.length - 1);
        }
        decl.metadata.forEach((InstanceMirror meta) {
          if (_fieldAnnotations.contains(meta.type)) {
            if (fields.containsKey(fieldName)) {
              throw 'Attribute annotation for $fieldName is defined more '
              'than once in $type';
            }
            fields[fieldName] = meta.reflectee as AttrFieldAnnotation;
          }
        });
      }
    });
    return fields;
  }
}
