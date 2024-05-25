using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[UnityEngine.Scripting.Preserve]
public class BloomRenderer : PostProcessEffectRenderer<BloomSettings>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Custom/Bloom"));

        sheet.properties.SetColor("_BloomColor", settings.bloomColor);
        sheet.properties.SetFloat("_BloomStrength", settings.bloomStrength);


        RenderTexture buffer0 = RenderTexture.GetTemporary(context.width, context.height, 0);
        context.command.BlitFullscreenTriangle(context.source, buffer0, sheet, 2);

        for (int i = 0; i < settings.iteratorTimes; i++)
        {
            RenderTexture buffer1 = RenderTexture.GetTemporary(context.width, context.height, 0);
            context.command.BlitFullscreenTriangle(buffer0, buffer1, sheet, 0);

            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
            buffer1 = RenderTexture.GetTemporary(context.width, context.height, 0);
            context.command.BlitFullscreenTriangle(buffer0, buffer1, sheet, 1);

            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
        }

        sheet.properties.SetTexture("_BloomTex", buffer0);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 3);
        RenderTexture.ReleaseTemporary(buffer0);

    }
}