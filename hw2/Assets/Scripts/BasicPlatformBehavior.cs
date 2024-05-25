using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class BasicPlatformBehavior : MonoBehaviour
{
    // Start is called before the first frame update
    private float speed = 0.5f;

    private float topY = 7f;

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        this.transform.Translate(0f, speed * Time.deltaTime, 0f, Space.World);
        if (this.transform.position.y > topY) selfDestroy();
    }

    public void selfDestroy()
    {
        Destroy(this.gameObject);
    }
}
