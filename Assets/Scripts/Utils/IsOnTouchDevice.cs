using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IsOnTouchDevice : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField] GameObject[] DesktopArray;
    [SerializeField] GameObject[] HandHeldArray;

    public Action mobileDeviceAction;
    public Action desktopDeviceAction;

    private void Awake()
    {
        if (SystemInfo.deviceType == DeviceType.Handheld)
        {
            if (mobileDeviceAction != null)
            {
                mobileDeviceAction.Invoke();
            }

            foreach (GameObject go in DesktopArray)
            {
                go.SetActive(false);
            }
            foreach (GameObject go in HandHeldArray)
            {
                go.SetActive(true);
            }

        }

        else
        {
            if (desktopDeviceAction != null)
            {
                mobileDeviceAction.Invoke();
            }

            foreach (GameObject go in DesktopArray)
            {
                go.SetActive(true);
            }
            foreach (GameObject go in HandHeldArray)
            {
                go.SetActive(false);
            }
        }

    }

}
