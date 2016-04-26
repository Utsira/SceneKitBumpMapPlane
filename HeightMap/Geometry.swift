//
//  HeightMap.swift
//  HeightMap
//
//  Created by Oliver Dew on 25/04/2016.
//  Copyright © 2016 Salt Pig. All rights reserved.
//
// adapting from: https://www.snip2code.com/Snippet/790183/Creating-Custom-3D-Geometry-with-Swift--

import Foundation
import SceneKit
import SceneKit.ModelIO

func bumpyPlane (width: Int = 10, length: Int = 10) -> SCNGeometry {
    var vertices:[SCNVector3] = []
    var texCoords:[vector_float2] = []
    var faces:[Int32] = []
    let size:Float = 1.0
    let pointsAcross = width + 1
    let halfWidth = Float(width) / 2
    let halfLength = Float(length) / 2
    let generator = PerlinGenerator()
    generator.octaves = 3
    generator.persistence = 0.7
    generator.zoom = 14.3
    
    for z in 0...length {
        for x in 0...width {
            let floatX = Float(x) - halfWidth
            let floatZ = Float(z) - halfLength
            let noise = generator.perlinNoise(floatX, y: floatZ)
            vertices.append( SCNVector3Make(floatX * size, noise * size * 1.5, floatZ * size))
            texCoords.append( vector_float2(x: Float(x)/Float(width), y: Float(z)/Float(length)))
            // print(texCoords.last)
            if z > 0 && x > 0 {
                let a = Int32(vertices.count) - 1
                let b = a-1
                let c = b-pointsAcross
                let d = a-pointsAcross
                faces += [a,c,b, a,d,c] //[a,b,c, c,d,a] // 2 triangular faces, wound anti-clockwise
            }
            
        }
    }

    let geometry = createGeometry(
        vertices, texCoords: texCoords, indices: faces,
        primitiveType: SCNGeometryPrimitiveType.Triangles)
    
    // round-trip to ModelIO to calculate normals
    let mdlMesh = MDLMesh(SCNGeometry: geometry)
    mdlMesh.addNormalsWithAttributeNamed("MDLVertexAttributeNormal", creaseThreshold: 0) //the documentation says first value can be nil, this leads to a runtime error though
    
    let geometryWithNormals = SCNGeometry(MDLMesh: mdlMesh)
    //Add materials
    let material = SCNMaterial()
    material.diffuse.contents = UIImage(named: "art.scnassets/Barren Reds.jpg") //UIColor.blueColor()
    material.specular.contents = UIColor.whiteColor()
    material.shininess = 2
    print(material.lightingModelName)
    // material.lightingModelName = SCNLightingModelPhong
    geometryWithNormals.materials = [material]
    geometryWithNormals.subdivisionLevel = 1
    
    return geometryWithNormals
}

// Creates a geometry object from given vertex, index and type data
func createGeometry(vertices:[SCNVector3], texCoords:[vector_float2]? = nil, indices:[Int32], primitiveType:SCNGeometryPrimitiveType) -> SCNGeometry {
        
    // Computed property that indicates the number of primitives to create based on primitive type
    var primitiveCount:Int {
        get {
            switch primitiveType {
            case SCNGeometryPrimitiveType.Line:
                return indices.count / 2
            case SCNGeometryPrimitiveType.Point:
                return indices.count
            case SCNGeometryPrimitiveType.Triangles,
                 SCNGeometryPrimitiveType.TriangleStrip:
                return indices.count / 3
            }
        }
    }
    
    // Create the source and elements in the appropriate format
    let data = NSData(bytes: vertices, length: sizeof(SCNVector3) * vertices.count)
    let vertexSource = SCNGeometrySource(vertices: vertices, count: vertices.count)
//    let vertexSource = SCNGeometrySource(
//        data: data, semantic: SCNGeometrySourceSemanticVertex,
//        vectorCount: vertices.count, floatComponents: true, componentsPerVector: 3,
//        bytesPerComponent: sizeof(Float), dataOffset: 0, dataStride: sizeof(SCNVector3))
    let indexData = NSData(bytes: indices, length: sizeof(Int32) * indices.count)
    let element = SCNGeometryElement(
        data: indexData, primitiveType: primitiveType,
        primitiveCount: primitiveCount, bytesPerIndex: sizeof(Int32))
    if texCoords == nil {
        return SCNGeometry(sources: [vertexSource], elements: [element])
    }else{
        let uvData = NSData(bytes: texCoords!, length: sizeof(vector_float2) * texCoords!.count)
        // let uvSource = SCNGeometrySource(textureCoordinates: texCoords!, count: texCoords!.count) //this requires CGPoint, but gives error SCNGeometrySource::initWithMeshSource unexpected component type 6
        let uvSource = SCNGeometrySource(data: uvData,
                                         semantic: SCNGeometrySourceSemanticTexcoord,
                                         vectorCount: texCoords!.count,
                                         floatComponents: true,
                                         componentsPerVector: 2,
                                         bytesPerComponent: sizeof(Float),
                                         dataOffset: 0,
                                         dataStride: sizeof(vector_float2))
        return SCNGeometry(sources: [vertexSource, uvSource], elements: [element])
    }
    
    
}
