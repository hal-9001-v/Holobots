using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LanguageContext : MonoBehaviour
{
    static LanguageContext _instance;

    public Language currentLanguage { get; private set; }

    private void Start()
    {
        if (_instance)
        {
            _instance.UpdateLanguageChangeables();
            Destroy(gameObject);
        }
        else
        {

            _instance = this;
            transform.parent = null;
            DontDestroyOnLoad(gameObject);
            ChangeLanguage(Language.English);
        }
    }

    public void ChangeLanguage(Language language)
    {
        if (language == currentLanguage) return;

        currentLanguage = language;

        UpdateLanguageChangeables();
    }

    public void UpdateLanguageChangeables()
    {
        foreach (var changeable in FindObjectsOfType<LanguageChangeable>())
        {
            changeable.ChangeLanguage(currentLanguage);
        }
    }

}
