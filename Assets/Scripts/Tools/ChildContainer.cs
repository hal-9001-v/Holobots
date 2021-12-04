using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChildContainer : MonoBehaviour
{

    public void SetGameobjectAsChild(GameObject child)
    {
        child.transform.parent = transform;
    }

}
