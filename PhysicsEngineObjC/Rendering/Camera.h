#pragma once

#include "MetalToCpp.h"

#include "Eigen/Dense"

#include <cmath>

struct Camera {
    Eigen::Vector3f _position;
    Eigen::Vector3f _eyeDirection;
    Eigen::Vector3f _upVector;
    
    float _fov = M_PI / 4.0;
    float aspectRatio = 16.0f / 9.0f;
    float nearPlane = 0.1f;
    float farPlane = 100.0f;
    
    Eigen::Affine3f _projectionMatrix;
    Eigen::Affine3f _viewMatrix;
    
    Camera(Eigen::Vector3f position = {0, 0, 0},
           Eigen::Vector3f eyeDirection = {0, 0, 1},
           Eigen::Vector3f upVector = {0, 1, 0}) :
    _position(position),
    _eyeDirection(eyeDirection),
    _upVector(upVector)
    {
        _projectionMatrix = Eigen::Affine3f::Identity();
        _projectionMatrix *= Eigen::Scaling(aspectRatio, 1.0f, 1.0f);
        _projectionMatrix *= Eigen::Scaling(1.0f, 1.0f, -(farPlane + nearPlane) / (farPlane - nearPlane));
        _projectionMatrix *= Eigen::Translation3f(0, 0, -2 * farPlane * nearPlane / (farPlane - nearPlane));
        
        _viewMatrix = Eigen::Affine3f::Identity();
        Eigen::Vector3f center = _position + _eyeDirection;
        Eigen::Vector3f f = (_position - center).normalized();
        Eigen::Vector3f r = _upVector.cross(f).normalized();
        Eigen::Vector3f u = f.cross(r);
        _viewMatrix.linear().col(0) = r;
        _viewMatrix.linear().col(1) = u;
        _viewMatrix.linear().col(2) = -f;
        _viewMatrix.translation() = -_position;
        
        Eigen::Affine3f viewProjectionMatrix = _viewMatrix * _projectionMatrix;
        auto renderEncoder = getRenderCommandEncoder();
        bindVertexBytes(renderEncoder,
                        viewProjectionMatrix,
                        12);
    }
};
