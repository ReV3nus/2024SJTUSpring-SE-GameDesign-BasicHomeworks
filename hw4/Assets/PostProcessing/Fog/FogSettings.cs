using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[UnityEngine.Scripting.Preserve]
[Serializable]
[PostProcess(typeof(FogRenderer), PostProcessEvent.AfterStack, "Custom/Fog")]
public class FogSettings : PostProcessEffectSettings
{
    [Range(0f, 10f), Tooltip("Density for Fog.")]
    public FloatParameter fogDensity = new FloatParameter { value = 1f };

    [Tooltip("Color of fog.")]
    public ColorParameter fogColor = new ColorParameter { value = Color.white };

    [Range(0f, 10f), Tooltip("Maximum height of fog.")]
    public FloatParameter fogHeight = new FloatParameter { value = 2f };

    [Tooltip("Fog Noise Texture.")]
    public TextureParameter noiseTex = new TextureParameter { };

    [Range(-1f, 1f), Tooltip("Fog animation X speed.")]
    public FloatParameter fogXSpeed = new FloatParameter { value = 0.5f };

    [Range(-1f, 1f), Tooltip("Fog animation Y speed.")]
    public FloatParameter fogYSpeed = new FloatParameter { value = 0.5f };

    [Range(0f, 5f), Tooltip("Strength of fog noise.")]
    public FloatParameter noiseStrength = new FloatParameter { value = 1f };

    [Range(0.1f, 10f), Tooltip("Scale of fog noise.")]
    public FloatParameter noiseScale = new FloatParameter { value = 1f };

}