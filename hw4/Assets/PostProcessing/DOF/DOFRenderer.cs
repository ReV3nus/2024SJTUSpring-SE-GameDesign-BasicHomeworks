using NUnit.Framework.Internal;
using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;
using static Unity.VisualScripting.Member;

[UnityEngine.Scripting.Preserve]
public class DOFRenderer : PostProcessEffectRenderer<DOFSettings>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Custom/DOF"));

        sheet.properties.SetFloat("_BlurStrength", settings.blurStrength);

        sheet.properties.SetFloat("_MinFocusDistance", settings.minFocusDistance);
        sheet.properties.SetFloat("_MaxFocusDistance", settings.maxFocusDistance);
        sheet.properties.SetFloat("_LessScale", settings.lessScale);
        sheet.properties.SetFloat("_MoreScale", settings.moreScale);


        RenderTexture buffer0 = RenderTexture.GetTemporary(context.width, context.height, 0);
        context.command.BlitFullscreenTriangle(context.source, buffer0);

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

        sheet.properties.SetTexture("_BlurTex", buffer0);
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 2);

    }
}