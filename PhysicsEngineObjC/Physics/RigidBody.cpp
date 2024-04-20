#include "RigidBody.h"
    
void RigidBody::update(double dt)
{
    _position += _position + _velocity * dt + _acceleration * ( dt * dt * 0.5);
    _velocity += _velocity + (_acceleration * dt * 0.5);
    _acceleration += _acceleration;
    
    Eigen::Vector3f translation(_position);
    _modelTransform.translation() = translation;
}

Vector3f RigidBody::applyForces() const
{
    Vector3f gravAcceleration = Vector3f{0.0, 0.0, -9.81 };
    Vector3f dragForce = 0.5 * _drag * (_velocity * _velocity); // D = 0.5 * (rho * C * Area * vel^2)
    Vector3f dragAcceleration = dragForce / _mass; // a = F/m
    return gravAcceleration - dragAcceleration;
}
