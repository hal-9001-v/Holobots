using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Selectable : MonoBehaviour
{
    

    public Action clickAction;
    public Action selectAction;
    public Action deselectAction;

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


}
