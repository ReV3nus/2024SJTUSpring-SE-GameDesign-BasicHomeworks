using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    [Header("Camera Settings")]
    public Transform player;
    public Vector3 playerFocusOffset;
    public Vector3 PerspectiveOffset;
    public float offsetDistance;
    public float mouseSensitivity;
    public Vector3 cameraFaceDir = new Vector3(0f, 0f, 1f);
    private Vector3 cameraOffsetDir;
    private Vector3 cameraBaseDir = new Vector3(0f, 0f, 1f);
    public Vector3 cameraFaceAngles = new Vector3(0f, 0f, 0f);
    public float maxAngleY;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
        UpdatePosition();
    }
    private void Update()
    {
        
        float mouseX = Input.GetAxisRaw("Mouse X") * mouseSensitivity * Time.timeScale;
        float mouseY = Input.GetAxisRaw("Mouse Y") * mouseSensitivity * Time.timeScale;

        cameraFaceAngles += new Vector3(mouseX, mouseY, 0f);
        cameraFaceAngles.x %= 360f;
        if(cameraFaceAngles.y >= maxAngleY)
        {
            mouseY -= cameraFaceAngles.y - maxAngleY;
            cameraFaceAngles.y = maxAngleY;
        }
        else if(cameraFaceAngles.y <= -maxAngleY)
        {
            mouseY += -maxAngleY - cameraFaceAngles.y;
            cameraFaceAngles.y = -maxAngleY;
        }
        Quaternion rotation = Quaternion.Euler(-cameraFaceAngles.y, cameraFaceAngles.x, 0);
        cameraFaceDir = rotation * cameraBaseDir;
        cameraOffsetDir = rotation * PerspectiveOffset;
        UpdatePosition();
    }
    private void UpdatePosition()
    {
        transform.position = (player.transform.position + playerFocusOffset) +
            offsetDistance * (-cameraFaceDir);
        transform.LookAt((player.transform.position + playerFocusOffset), Vector3.up);
        transform.position += cameraOffsetDir;
    }
}
