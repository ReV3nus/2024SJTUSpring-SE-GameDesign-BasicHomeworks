using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class GameController : MonoBehaviour
{
    public GameObject prefab;
    //public TextMeshPro Text;
    public TextMeshProUGUI textMeshPro;

    public int SnackCount = 8;
    private float Score = 0.0f;
    // Start is called before the first frame update
    void Start()
    {
        for (int i = 0; i < SnackCount; i++) InstantiatePrefab();
        Score = 0.0f;
        //Text = GameObject.Find("Score").GetComponent<TextMeshPro>();
    }

    // Update is called once per frame
    void Update()
    {
    }
    public void InstantiatePrefab()
    {
        float posX = Random.Range(-5f, 5f);
        float posZ = Random.Range(-5f, 5f);
        Instantiate(prefab, new Vector3(posX, 0f, posZ), Quaternion.Euler(0f, 0f, 0f));
    }
    public void onSnackEaten(float scale)
    {
        Score += 10.0f * scale / 0.2f;
        textMeshPro.text = "Score: " + Mathf.Round(Score * 100) / 100f;
    }
}
