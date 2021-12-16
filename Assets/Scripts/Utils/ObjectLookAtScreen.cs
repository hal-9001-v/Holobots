using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Transform))]
public class ObjectLookAtScreen : MonoBehaviour
{
    Camera _gameCamera;
    private void Awake()
    {
        _gameCamera = FindObjectOfType<Camera>();
    }

    private void Update()
    {
        transform.LookAt(_gameCamera.transform);
        transform.Rotate(0, 180, 0);
    }

}
