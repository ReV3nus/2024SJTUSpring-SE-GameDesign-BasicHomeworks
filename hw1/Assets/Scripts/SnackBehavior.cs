using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SnackBehavior : MonoBehaviour
{

    private float Timer = 0.0f;
    private float posX, posZ;

    public float rotateSpeed = 20.0f;
    public float floatSpeed = 1.5f;
    public float lifeTime = 10.0f;

    private GameController gameController;
    // Start is called before the first frame update
    void Start()
    {
        Timer = 0.0f;
        posX = transform.position.x;
        posZ = transform.position.z;
        gameController = GameObject.Find("GameController").GetComponent<GameController>();
    }

    // Update is called once per frame
    void Update()
    {
        Timer += Time.deltaTime;
        transform.position = new Vector3(posX, 0.3f + 0.1f * Mathf.Sin(floatSpeed * Timer), posZ);
        transform.rotation = Quaternion.Euler(0.0f, rotateSpeed * Timer, 0.0f);
        float scale = 0.2f * (lifeTime - Timer) / lifeTime;
        if (scale < 0.01f)
            DestroySelf();
        transform.localScale = new Vector3(scale, scale, scale);
    }
    public void DestroySelf()
    {
        gameController.InstantiatePrefab();
        Destroy(this.gameObject);
    }
}
