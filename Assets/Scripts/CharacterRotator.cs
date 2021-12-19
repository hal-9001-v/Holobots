using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterRotator : MonoBehaviour
{
    Vector3 _forward;

    float _elapsedTime;
    float _rotationDuration;

    Quaternion _startingRotation;
    Quaternion _targetRotation;

    bool _isRotating;

    private void FixedUpdate()
    {
        Rotate();
    }

    void Rotate()
    {
        if (!_isRotating) return;

        if (_elapsedTime < _rotationDuration)
        {
            _elapsedTime += Time.fixedDeltaTime;

            var rot = Quaternion.Lerp(_startingRotation, _targetRotation, _elapsedTime / _rotationDuration).eulerAngles;

            rot.z = 0;
            rot.x = 0;
            transform.eulerAngles = rot;

        }
        else
        {
            _isRotating = false;
        }

    }

    public void SetForward(Vector3 forward, float time)
    {
        _isRotating = true;

        _forward = forward;

        _startingRotation = transform.rotation;
        _targetRotation = Quaternion.LookRotation(_forward);

        _elapsedTime = 0;
        _rotationDuration = time;
    }

}
