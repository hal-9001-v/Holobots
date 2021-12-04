using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;


public class CameraMovement : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] Transform _cameraFollow;
    [SerializeField] Transform _cameraAxis;
    [SerializeField] Camera _camera;
    [SerializeField] CinemachineVirtualCamera _virtualCamera;




    [SerializeField] Transform[] _cameraLimiters;

    Rigidbody _followRigidbody;

    [Header("Settings")]
    [SerializeField] [Range(50f, 250f)] float _rotationSpeed = 1;
    [SerializeField] [Range(0f, 10f)] float _movementSpeed = 1;
    [SerializeField] [Range(0f, 10f)] float _fovChange = 1;

    float _rotationInput;
    bool _isRotating;

    Vector2 _movementInput;
    bool _isMoving;

    private void Start()
    {
        var inputMapContainer = FindObjectOfType<InputMapContainer>();

        if (inputMapContainer)
        {
            inputMapContainer.inputMap.Camera.RotateCamera.performed += ctx =>
            {
                _rotationInput = ctx.ReadValue<float>();
                _isRotating = true;
            };

            inputMapContainer.inputMap.Camera.RotateCamera.canceled += ctx =>
            {
                _isRotating = false;
            };

            inputMapContainer.inputMap.Camera.MoveCamera.performed += ctx =>
            {
                _movementInput = ctx.ReadValue<Vector2>();
                _isMoving = true;

            };

            inputMapContainer.inputMap.Camera.MoveCamera.canceled += ctx =>
            {
                _isMoving = false;

                _followRigidbody.velocity = Vector3.zero;
            };

            inputMapContainer.inputMap.Camera.Scroll.performed += ctx =>
            {
                if (ctx.ReadValue<float>() > 0)
                {
                    _virtualCamera.m_Lens.FieldOfView += _fovChange;
                }
                else
                if (ctx.ReadValue<float>() > 0)
                {
                    _virtualCamera.m_Lens.FieldOfView -= _fovChange;
                }
            };

        }


        if (_cameraFollow)
        {
            _followRigidbody = _cameraFollow.GetComponent<Rigidbody>();
        }
    }

    private void Update()
    {
        if (_isRotating)
        {
            RotateCamera(_rotationInput);
        }
        else if (_isMoving)
        {
            MoveCamera(_movementInput);
        }


    }

    public void LookAt(Vector3 position)
    {
        position.y = _cameraFollow.position.y;

        _cameraFollow.position = position;
    }

    void RotateCamera(float input)
    {
        if (_cameraAxis)
        {
            _cameraAxis.Rotate(Vector3.up, input * _rotationSpeed * Time.deltaTime);
        }
    }

    void MoveCamera(Vector2 input)
    {
        Vector3 fixedForward = _camera.transform.forward;
        fixedForward.y = 0;
        fixedForward.Normalize();

        Vector3 fixedRight = _camera.transform.right;
        fixedRight.y = 0;
        fixedRight.Normalize();

        var targetVelocity = input.x * fixedRight + input.y * fixedForward;
        targetVelocity *= _movementSpeed * Time.fixedDeltaTime;

        //_followRigidbody.AddForce(targetVelocity - _followRigidbody.velocity, ForceMode.VelocityChange);

        transform.position += targetVelocity;
    }

}
