#import <Cocoa/Cocoa.h>

#include "Engine.h"
#include "MetalToCpp.h"
#include "Renderer.h"
#include "ViewController.h"

int main(int argc, const char * argv[]) {
    
//    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
//    ViewController *viewController = [storyboard instantiateControllerWithIdentifier:@"ViewController"];
//
//    MTKView *metalView = (MTKView*)viewController.view;
//    if (!metalView) {
//        NSLog(@"MTKView not found in the view hierarchy.");
//        return 1;
//    }
//
//    Renderer *renderer = [[Renderer alloc] initWithMetalKitView:metalView];
//    [renderer createRenderPassDescriptor:metalView.drawableSize];
    
//    PhysicsEngine engine;
//    RigidBody body_1;
//    Vector3f position_2 {0, 0, 0.5};
//    Vector3f velocity_2 {0.5, 0.5, 0};
//    RigidBody body_2 {position_2, velocity_2};
//    engine.addBody(&body_1);
//    engine.addBody(&body_2);
//    
//    engine._lastDrawTime = 0;
//    while (engine._lastDrawTime < 25) {
//        engine.update();
//        engine.bindModelMatrices();
//    }

    return NSApplicationMain(argc, argv);
}
