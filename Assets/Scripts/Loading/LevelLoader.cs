using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
public class LevelLoader : MonoBehaviour
{
    static LevelLoader _loader;
    private Slider slider;
    private Animator loadingAnimator;

    bool _loading;

    const string LoadTrigger = "Start";
    const string EndLoadTrigger = "End";

    private void Awake()
    {
        if (_loader)
        {
            DestroyImmediate(gameObject);
        }
        else
        {
            _loader = this;

            DontDestroyOnLoad(this);
            slider = GetComponentInChildren<Slider>();
            loadingAnimator = GetComponentInChildren<Animator>();
        }

    }

    public void LoadLevel(int index)
    {
        StartCoroutine(LoadAsync(index));
    }

    IEnumerator LoadAsync(int index)
    {
        if (!_loading)
        {
            _loading = true;
            loadingAnimator.SetTrigger(LoadTrigger);
            yield return new WaitForSeconds(2f);
            loadingAnimator.ResetTrigger(LoadTrigger);
            AsyncOperation op = SceneManager.LoadSceneAsync(index);

            while (!op.isDone)
            {
                float progress = Mathf.Clamp01(op.progress / .9f);
                slider.value = progress;
                Debug.Log(progress);

                yield return null;
            }
            loadingAnimator.SetTrigger(EndLoadTrigger);
            yield return new WaitForSeconds(2f);
            slider.value = 0f;
            loadingAnimator.ResetTrigger(EndLoadTrigger);
            _loading = false;
        }
    }

}
