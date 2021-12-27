using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UiHider : MonoBehaviour
{
    static CanvasGroup backgroundCanvas;

    void Awake()
    {
        backgroundCanvas = GetComponent<CanvasGroup>();
    }
    public  static void DisableUI(){

        backgroundCanvas.alpha = 0f;

    }
    public static void EnableUI(){

        backgroundCanvas.alpha = 1f;

    }
}
