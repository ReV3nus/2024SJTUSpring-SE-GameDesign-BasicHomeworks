using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(LineStyleRender), PostProcessEvent.AfterStack, "TMP/LineStyle")]
public class LineStyle : PostProcessEffectSettings
{
    [Range(0f, 20f), Tooltip("Strength of line.")]
    public FloatParameter lineStrength = new FloatParameter { value = 1f };

    [ColorUsage(false), Tooltip("Color of line.")]
    public ColorParameter lineColor = new ColorParameter { value = Color.black };

    [ColorUsage(false), Tooltip("Color of base.")]
    public ColorParameter baseColor = new ColorParameter { value = Color.white };

}