using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

[RequireComponent(typeof(Rigidbody))]
public class CameraMovement : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] Transform _cameraFollow;
    [SerializeField] Transform _cameraTarget;
    [SerializeField] Transform _cameraAxis;
    [SerializeField] Camera _camera;
    [SerializeField] CinemachineVirtualCamera _virtualCamera;

    public Rigidbody _followRigidbody;

    [Header("Settings")]
    [SerializeField] [Range(50f, 250f)] float _rotationSpeed = 1;
    [SerializeField] [Range(0f, 20f)] float _movementSpeed = 1;
    [SerializeField] [Range(0f, 10f)] float _fovChange = 1;

    float _rotationInput;
    bool _isRotating;

    Vector2 _movementInput;
    bool _isMoving;

    private void Start()
    {
        var inputMap = new GameInput();

        inputMap.Camera.RotateCamera.Enable();
        inputMap.Camera.MoveCamera.Enable();
        inputMap.Camera.Scroll.Enable();


        if (_cameraFollow)
        {
            _followRigidbody = _cameraFollow.GetComponent<Rigidbody>();
        }

        inputMap.Camera.RotateCamera.performed += ctx =>
        {
            _rotationInput = ctx.ReadValue<float>();
            _isRotating = true;
        };

        inputMap.Camera.RotateCamera.canceled += ctx =>
        {
            _isRotating = false;
        };

        inputMap.Camera.MoveCamera.performed += ctx =>
        {
            _movementInput = ctx.ReadValue<Vector2>();
            _isMoving = true;

        };

        inputMap.Camera.MoveCamera.canceled += ctx =>
        {
            //Dont make questions
            if (this && _followRigidbody)
            {
                _isMoving = false;

                _followRigidbody.velocity = Vector3.zero;
            }
        };

        inputMap.Camera.Scroll.performed += ctx =>
        {
            if (ctx.ReadValue<float>() < 0)
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

    private void Update()
    {
        if (_cameraFollow) _followRigidbody = _cameraFollow.GetComponent<Rigidbody>();

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

    public void FixLookAt(Transform target)
    {
        _virtualCamera.LookAt = target;
        _virtualCamera.Follow = target;
    }

    public void FreeCamera()
    {
        FixLookAt(_cameraTarget);
    }

    public IEnumerator FixLookAtC(Transform t)
    {
        yield return new WaitForSeconds(0.4f);

        FixLookAt(t);
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
        targetVelocity *= _movementSpeed * Time.deltaTime;

        //_followRigidbody.AddForce(targetVelocity - _followRigidbody.velocity, ForceMode.VelocityChange);

        transform.position += targetVelocity;
    }

}
