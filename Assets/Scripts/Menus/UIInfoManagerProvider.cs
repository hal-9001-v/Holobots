using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIInfoManagerProvider : MonoBehaviour
{
    [Header("References")]
    [SerializeField]UIInfoManager _handUIInfo;
    [SerializeField]UIInfoManager _desktopUIInfo;

    public UIInfoManager infoManager
    {
        get
        {
            if (SystemInfo.deviceType == DeviceType.Handheld)
            {
                return _handUIInfo;
            }
            return _desktopUIInfo;
        }
    }
}
