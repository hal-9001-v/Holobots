using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Collider))]
public class Selectable : MonoBehaviour
{
    Collider _collider;

    public Action clickAction;
    public Action selectAction;
    public Action deselectAction;

    private void Awake()
    {
        _collider = GetComponent<Collider>();
    }

    public void Select()
    {

        if (selectAction != null)
            selectAction.Invoke();
    }

    public void Deselect()
    {
        if (deselectAction != null)
            deselectAction.Invoke();

    }

    public void Click()
    {
        if (clickAction != null)
            clickAction.Invoke();

    }

    public void EnableSelection()
    {
        _collider.enabled = true;
    }

    public void DisableSelection()
    {
        _collider.enabled = false;
    }


}
