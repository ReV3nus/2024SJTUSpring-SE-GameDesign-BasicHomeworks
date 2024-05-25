using NUnit.Framework.Internal;
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using static Unity.VisualScripting.Member;

[UnityEngine.Scripting.Preserve]
public class FogRenderer : PostProcessEffectRenderer<FogSettings>
{
    private Camera _MyCamera;
    private Transform _MyCameraTransform;

    public Camera Camera
    {
        get
        {
            if (_MyCamera == null)
            {
                _MyCamera = GameObject.Find("Main Camera").GetComponent<Camera>();
            }
            return _MyCamera;
        }
    }

    public Transform CameraTransform
    {
        get
        {
            if (_MyCameraTransform == null)
            {
                _MyCameraTransform = Camera.transform;
            }

            return _MyCameraTransform;
        }
    }

    public override void Render(PostProcessRenderContext context)
    {
        Matrix4x4 frustumCorners = Matrix4x4.identity;
        float vFov = Camera.fieldOfView;
        float near = Camera.nearClipPlane;
        float aspect = Camera.aspect;

        float halfHeight = near * Mathf.Tan(vFov * 0.5f * Mathf.Deg2Rad);
        Vector3 toRight = CameraTransform.right * halfHeight * aspect;
        Vector3 toTop = CameraTransform.up * halfHeight;

        var forward = CameraTransform.forward;
        Vector3 topLeft = forward * near + toTop - toRight;
        float scale = topLeft.magnitude / near;

        topLeft.Normalize();
        topLeft *= scale;

        Vector3 topRight = forward * near + toRight + toTop;
        topRight.Normalize();
        topRight *= scale;

        Vector3 bottomLeft = forward * near - toTop - toRight;
        bottomLeft.Normalize();
        bottomLeft *= scale;

        Vector3 bottomRight = forward * near + toRight - toTop;
        bottomRight.Normalize();
        bottomRight *= scale;

        frustumCorners.SetRow(0, bottomLeft);
        frustumCorners.SetRow(1, bottomRight);
        frustumCorners.SetRow(2, topLeft);
        frustumCorners.SetRow(3, topRight);
        //Debug.Log(frustumCorners);


        var sheet = context.propertySheets.Get(Shader.Find("Custom/Fog"));

        sheet.properties.SetFloat("_FogDensity", settings.fogDensity);
        sheet.properties.SetFloat("_FogHeight", settings.fogHeight);
        sheet.properties.SetColor("_FogColor", settings.fogColor);
        sheet.properties.SetMatrix("_FrustumCornersRay", frustumCorners);
        sheet.properties.SetTexture("_NoiseTex", settings.noiseTex);
        sheet.properties.SetFloat("_FogXSpeed", settings.fogXSpeed);
        sheet.properties.SetFloat("_FogYSpeed", settings.fogYSpeed);
        sheet.properties.SetFloat("_NoiseStrength", settings.noiseStrength);
        sheet.properties.SetFloat("_NoiseScale", settings.noiseScale);

        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);

    }
}