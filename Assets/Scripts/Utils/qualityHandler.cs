using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class qualityHandler : MonoBehaviour
{

    [SerializeField] GameObject pp;
    // Start is called before the first frame update
    void Start()
    {
        if(SystemInfo.deviceType == DeviceType.Handheld) {
            
            pp.SetActive(false);

        } else pp.SetActive(true);
    }

}

