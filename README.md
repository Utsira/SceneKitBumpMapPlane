# SceneKitBumpMapPlane
Using perlin noise to create a height-mapped terrain plain in Swift 2 and SceneKit

![BumpyPlane](/BumpyPlane.jpg)

ModelIO is used to create the normals and the skybox

## Points to Note

- There is a bug in SceneKit where `SCNPhysicsShapeTypeConcavePolyhedron` ignores the friction setting, setting it to zero. So the terrain is very slippery, limiting its usefulness
- If you set the geometry `subdivisionLevel` before you create the physics body, the physics body is also subdivided. Here, I set `subdivisionLevel` after setting up physics body, so that the mesh is more detailed than the physics body.
- SkyBox doesn't seem to display on older devices (eg iPhone4S)

