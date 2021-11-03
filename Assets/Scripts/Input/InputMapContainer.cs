using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputMapContainer : MonoBehaviour
{

    public GameInput inputMap;
    private void Awake()
    {
        inputMap = new GameInput();

        inputMap.Enable();
    }

}
