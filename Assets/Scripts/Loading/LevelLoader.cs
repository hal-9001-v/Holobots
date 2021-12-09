 using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
public class LevelLoader : MonoBehaviour
{
    public LevelLoader[] _loader;
    
    private  Slider slider;

     private Animator loadingAnimator; 
    bool loading;
    private void Awake() {
        
        _loader = FindObjectsOfType<LevelLoader>();
        if(_loader.Length < 2) {

            DontDestroyOnLoad(this); 
            slider = GetComponentInChildren<Slider>();
            loadingAnimator = GetComponentInChildren<Animator>();
        } else{

            slider = GetComponentInChildren<Slider>();
            loadingAnimator = GetComponentInChildren<Animator>();
            Destroy(this.gameObject);
        
        }

    }
    
    public void LoadLevel(int index){

        StartCoroutine(LoadAsync(index));
    }

    IEnumerator LoadAsync(int index){
        if(!loading){
        loading = true;
        loadingAnimator.SetTrigger("Start");
        yield return new WaitForSeconds(2f);
        loadingAnimator.ResetTrigger("Start");
        AsyncOperation op = SceneManager.LoadSceneAsync(index);
        while(!op.isDone){
            float progress = Mathf.Clamp01(op.progress / .9f);
            slider.value = progress;
            Debug.Log(progress);

            yield return null;
        }
        loadingAnimator.SetTrigger("End");
        yield return new WaitForSeconds(2f);
        slider.value = 0f;
        loadingAnimator.ResetTrigger("End");
        loading = false;
     }
    }

}
