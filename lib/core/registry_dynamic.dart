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
    var metadata = [];
    if(cm.superclass != null) {
      metadata = this.call(cm.superclass.reflectedType);
    }
    metadata = _mergeMetadata(metadata,
        cm.metadata.map((InstanceMirror im) => map(type, im.reflectee) ));
    return metadata;
  }

  Iterable _mergeMetadata(
      Iterable superClassMetadataList, Iterable classMetadataList) {

    if(superClassMetadataList == null || superClassMetadataList.isEmpty)
      return classMetadataList;
    if(classMetadataList == null || classMetadataList.isEmpty)
      return superClassMetadataList;

    var superClassMetadata = superClassMetadataList.first;
    var classMetadata = classMetadataList.first;

    if(superClassMetadata == null && classMetadata != null)
      return [classMetadata];

    if( superClassMetadata is NgAnnotation && classMetadata is NgAnnotation ) {
      if (superClassMetadata.map != null && classMetadata.map != null) {
        var newDirective = classMetadata.cloneWithNewMap(
            _mergeMaps(superClassMetadata.map, classMetadata.map));
        return [newDirective];
      }
    }
    return [classMetadata];
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
