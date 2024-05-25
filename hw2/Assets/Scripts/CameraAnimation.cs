using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class CameraAnimation : MonoBehaviour
{
    // Start is called before the first frame update
    public float animationDuration;
    public float targetSize;

    private Transform playerTransform;
    private Camera thisCamera;
    void Start()
    {
        playerTransform = GameObject.Find("Player").transform;
        thisCamera = GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {

    }
    public void Animate()
    {
        StartCoroutine(MoveAndScaleAnimation());
        StartCoroutine(StopingTime());
    }
    IEnumerator MoveAndScaleAnimation()
    {
        Vector3 initialPosition = transform.position;
        float initialSize = thisCamera.orthographicSize;

        float elapsedTime = 0f;

        while (elapsedTime < animationDuration)
        {
            float t = (1 - Mathf.SmoothStep(0f, 1f, 1-(elapsedTime / animationDuration)));

            transform.position = Vector3.Lerp(initialPosition, new Vector3(playerTransform.position.x, playerTransform.position.y, 5f), t);
            thisCamera.orthographicSize = Mathf.Lerp(initialSize, targetSize, t);

            elapsedTime += Time.deltaTime;
            yield return null;
        }

        // Ensure the object reaches the exact target position and scale
        transform.position = new Vector3(playerTransform.position.x, playerTransform.position.y, 5f);
        thisCamera.orthographicSize = targetSize;
    }

    IEnumerator StopingTime()
    {
        Time.timeScale = 0.1f;
        float stopTime = 0.5f;

        float elapsedTime = 0f;

        while (elapsedTime < stopTime)
        {
            elapsedTime += Time.deltaTime;
            yield return null;
        }

        Time.timeScale = 0f;
    }
}
