using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;
using System.Linq;
public class CircleSync : MonoBehaviour
{
    [Header("Settings")]
    [SerializeField] [Range(0, 5000)] float _raycastRange = 2000;

    [Space(5)]

    [SerializeField] [Range(0.1f, 2f)] float _lerpDuration = 0.5f;
    [SerializeField] [Range(0, 20)] float _circleSize;
    [SerializeField] [Range(0, 1)] float _circleSmoothness;
    [SerializeField] [Range(0, 1)] float _circleOpacity;

    [SerializeField] LayerMask _mask;

    static int PosID = Shader.PropertyToID("_PlayerPos");
    static int SizeID = Shader.PropertyToID("_Size");
    static int SmoothID = Shader.PropertyToID("_Smoothness");
    static int OpID = Shader.PropertyToID("_Opacity");

    Renderer[] _renderers;
    Camera _camera;

    Target currentUnit;
    UIInfoManager ui;

    float timeElapsed;

    const float startValue = 0;
    const float endValue = 2;

    private void Start()
    {
        ui = FindObjectOfType<UIInfoManager>();
        _camera = FindObjectOfType<Camera>();

        _renderers = GetComponentsInChildren<Renderer>();

        foreach (var renderer in _renderers)
        {
            renderer.material.SetFloat(SizeID, 0);
            renderer.material.SetFloat(SmoothID, _circleSmoothness);
            renderer.material.SetFloat(OpID, _circleOpacity);
        }
    }

    void SetSize(float value)
    {
        foreach (var renderer in _renderers)
        {
            renderer.material.SetFloat(SizeID, value);
        }
    }

    void SetPosition(Vector3 position)
    {
        foreach (var renderer in _renderers)
        {
            renderer.material.SetVector(PosID, position);
        }
    }

    private void Update()
    {
        currentUnit = ui.currentTarget;
        //Right now, it doesnt stack up objects
        if (currentUnit != null)
        {
            Vector3 targetPosition = currentUnit.transform.position - new Vector3(0, 1.5f, 0);

            var direction = (_camera.transform.position - targetPosition).normalized;
            var ray = new Ray(targetPosition, direction);

            RaycastHit hit;
            if (Physics.Raycast(ray, out hit, _raycastRange, _mask))
            {
                Debug.DrawLine(_camera.transform.position, hit.collider.transform.position, Color.green);

                if (hit.collider.gameObject == gameObject)
                {
                    var view = _camera.WorldToViewportPoint(currentUnit.transform.position);

                    SetPosition(view);

                    if (timeElapsed < _lerpDuration)
                    {
                        _circleSize = Mathf.Lerp(startValue, endValue, timeElapsed / _lerpDuration);
                        timeElapsed += Time.deltaTime;

                        SetSize(_circleSize);

                        /* Uncomment to change properties on real time
                        foreach (var renderer in _renderers)
                        {
                            renderer.material.SetFloat(SizeID, _circleSize);
                            renderer.material.SetFloat(SmoothID, _circleSmoothness);
                            renderer.material.SetFloat(OpID, _circleOpacity);
                        }
                        */

                    }

                }
            }
            else
            {
                if (timeElapsed > 0)
                {
                    timeElapsed = 0;

                    SetSize(startValue);

                }

            }
        }
    }
}
