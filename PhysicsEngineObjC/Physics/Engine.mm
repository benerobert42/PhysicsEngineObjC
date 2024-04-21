#include "Engine.h"

#include "RigidBody.h"

#include "MetalToCpp.h"

using namespace Eigen;

Renderer *renderer = getRenderer();

//void PhysicsEngine::checkCollisions(float dt) {
//    const float responseCoeff = 0.75f;
//    const size_t bodiesCount = _bodies.size();
//    // Iterate on all objects
//    for (int i = 0; i < bodiesCount; ++i) {
//        RigidBody* bodyA = _bodies[i];
//        // Iterate on object involved in new collision pairs
//        for (int j = i + 1; j < bodiesCount; ++j) {
//            RigidBody* bodyB = _bodies[j];
//            const Vector3f posDiff = bodyA->_position - bodyB->_position;
//            const float squaredDist = posDiff.squaredNorm();
//            const float minDist = bodyA->_radius + bodyB->_radius;
//            // Check overlapping
//            if (squaredDist < pow(minDist,2)) {
//                const float dist  = posDiff.norm();
//                const Vector3f posDiffNorm = posDiff.normalized();
//                const float massRatioA = bodyA->_radius / (bodyA->_radius + bodyB->_radius);
//                const float massRatioB = bodyB->_radius / (bodyA->_radius + bodyB->_radius);
//                const float delta = 0.5f * responseCoeff * (dist - minDist);
//                // Update positions
//                bodyA->_position -= posDiffNorm * (massRatioB * delta);
//                bodyB->_position += posDiffNorm * (massRatioA * delta);
//            }
//        }
//    }
//}
//
//void PhysicsEngine::applyConstraint() {
//    for (auto& body : _bodies) {
//        const Vector3f constraintVector = _constraintCenter - body->_position;
//        const float distance = constraintVector.squaredNorm();
//        if (distance > (_constraintRadius - body->_radius)) {
//            const Vector2f constraintVectorNorm = constraintVector.normalized();
//            body->_position = _constraintCenter - constraintVectorNorm * (_constraintRadius - body->_radius);
//        }
//    }
//}
//
void PhysicsEngine::update() {
    NSTimeInterval currentTime = CACurrentMediaTime();
    NSTimeInterval elapsedTime = currentTime - _lastDrawTime;

    if (elapsedTime >= _frameDuration) {
        _lastDrawTime = currentTime;
        updateObjects(elapsedTime);
    }
}

void PhysicsEngine::updateObjects(float dt) {
    for (auto body : _bodies) {
        body->update(dt);
    }
}

void PhysicsEngine::addBody(RigidBody* body) {
    _bodies.push_back(body);
}

void PhysicsEngine::bindModelMatrices() {
    for (auto body : _bodies) {
        auto renderEncoder = getRenderCommandEncoder();
        bindVertexBytes(renderEncoder,
                        body->_modelTransform,
                        2);
    }
}
    
    
