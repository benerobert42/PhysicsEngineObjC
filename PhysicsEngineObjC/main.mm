#import <Cocoa/Cocoa.h>

#include "Engine.h"

int main(int argc, const char * argv[]) {
    PhysicsEngine engine;
    RigidBody body_1;
    Vector3f position_2 {0, 0, 0.5};
    Vector3f velocity_2 {0.5, 0.5, 0};
    RigidBody body_2 {position_2, velocity_2};
    //RigidBody body_2{._position = {0, 0, 0.5}, ._velocity = {0.5, 0.5, 0}};
    engine.addBody(&body_1);
    engine.addBody(&body_2);
    while (engine._lastDrawTime < 25) {
        engine.update();
        engine.bindModelMatrixes();
    }
    return NSApplicationMain(argc, argv);
}
