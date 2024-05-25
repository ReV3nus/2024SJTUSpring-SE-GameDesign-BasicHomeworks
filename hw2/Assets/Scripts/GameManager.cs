using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    // Start is called before the first frame update
    static GameManager instance;
    public GameObject panel;
    public TextMeshProUGUI textMeshPro;
    public GameObject Camera;

    private float Timer = 0f;
    private void Awake()
    {
        if (instance != null)
            Destroy(gameObject);
        instance = this;
    }

    void Start()
    {
        instance.Timer = 0f;
    }

    // Update is called once per frame
    void Update()
    {
        instance.Timer += Time.deltaTime;
    }
    public static void GameOver()
    {
        instance.panel.SetActive(true);
        instance.Camera.GetComponent<CameraAnimation>().Animate();
        instance.textMeshPro.text = ((int)instance.Timer).ToString();
    }
    public void ExitGame()
    {
        Application.Quit();
    }
    public void RestartGame()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
        Time.timeScale = 1;
    }

}
