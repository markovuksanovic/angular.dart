library angular.core_dynamic;

import 'dart:mirrors';
import 'package:angular/core/annotation_src.dart';
import 'package:angular/core/registry.dart';

export 'package:angular/core/registry.dart' show
    MetadataExtractor;

var _fieldMetadataCache = new Map<Type, Map<String, AbstractNgFieldAnnotation>>();

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
    var metadata;
    if(cm.superclass != null) {
      metadata = this.call(cm.superclass.reflectedType);
    }
    metadata = _mergeMetadata(metadata, cm.metadata.map((InstanceMirror im) => map(type, im.reflectee) ));
    print(type);print(metadata.length);

    return metadata;
  }

  Iterable<InstanceMirror> _mergeMetadata(Iterable first, Iterable second) {
    if(first == null || first.isEmpty) return second;
    if(second == null || second.isEmpty) return first;
    if( first.first is NgAnnotation && second.first is NgAnnotation ) {
      if ((first.first as NgAnnotation).map != null && (second.first as NgAnnotation).map != null) {
        Map newMap = new Map();
        newMap.addAll((first.first as NgAnnotation).map);
        newMap.addAll((second.first as NgAnnotation).map);
        return [(first.first as NgAnnotation).cloneWithNewMap(newMap)];
      }
    }
    return second;
  }

  map(Type type, obj) {
    if (obj is AbstractNgAnnotation) {
      return mapDirectiveAnnotation(type, obj);
    } else {
      return obj;
    }
  }

  AbstractNgAnnotation mapDirectiveAnnotation(Type type, AbstractNgAnnotation annotation) {
    var match;
    var fieldMetadata = fieldMetadataExtractor(type);
    if (fieldMetadata.isNotEmpty) {
      var newMap = annotation.map == null ? {} : new Map.from(annotation.map);
      fieldMetadata.forEach((String fieldName, AbstractNgFieldAnnotation ann) {
        var attrName = ann.attrName;
        if (newMap.containsKey(attrName)) {
          throw 'Mapping for attribute $attrName is already defined (while '
          'processing annottation for field $fieldName of $type)';
        }
        newMap[attrName] = '${mappingSpec(ann)}$fieldName';
      });
      annotation = cloneWithNewMap(annotation, newMap);
    }
    return annotation;
  }


  Map<String, AbstractNgFieldAnnotation> fieldMetadataExtractor(Type type) =>
      _fieldMetadataCache.putIfAbsent(type, () => _fieldMetadataExtractor(type));

  Map<String, AbstractNgFieldAnnotation> _fieldMetadataExtractor(Type type) {
    ClassMirror cm = reflectType(type);
    final fields = <String, AbstractNgFieldAnnotation>{};
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
            fields[fieldName] = meta.reflectee as AbstractNgFieldAnnotation;
          }
        });
      }
    });
    return fields;
  }
}
