#import <Cocoa/Cocoa.h>

#include "Engine.h"
#include "MetalToCpp.h"
#include "Renderer.h"
#include "ViewController.h"

int main(int argc, const char * argv[]) {
    // Initialize view controller (if using storyboard, use the storyboard identifier instead)
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil]; // Replace "Main" with your storyboard name
    ViewController *viewController = [storyboard instantiateControllerWithIdentifier:@"ViewController"]; // Replace "ViewController" with your view controller identifier


    // Get Metal view from view controller (assuming it's the root view)
    MTKView *metalView = (MTKView*)viewController.view;

    if (!metalView) {
        NSLog(@"MTKView not found in the view hierarchy.");
        return 1;
    }

    // Initialize renderer with Metal view
    Renderer *renderer = [[Renderer alloc] initWithMetalKitView:metalView];

    // Create render pass descriptor with drawable size
    [renderer createRenderPassDescriptor:metalView.drawableSize];

    // Initialize physics engine and rigid bodies
    PhysicsEngine engine;
    RigidBody body_1;
    Vector3f position_2 {0, 0, 0.5};
    Vector3f velocity_2 {0.5, 0.5, 0};
    RigidBody body_2 {position_2, velocity_2};
    engine.addBody(&body_1);
    engine.addBody(&body_2);

    // Rendering loop (ensure proper rendering setup and update logic)
    while (engine._lastDrawTime < 25) {
        engine.update();
        engine.bindModelMatrices(); // Assuming this is for updating model matrices in renderer
        // Call renderer to render the scene
        // This could be something like: [renderer drawScene];
    }

    return NSApplicationMain(argc, argv);
}
