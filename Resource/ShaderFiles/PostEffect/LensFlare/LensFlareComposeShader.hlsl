
//入力情報
RWTexture2D<float4> SceneImg : register(u0);

//入力情報
RWTexture2D<float4> LensFlareImg : register(u1);

//出力先UAV  
RWTexture2D<float4> OutputImg : register(u2);

[numthreads(16, 16, 1)]
void main(uint3 DTid : SV_DispatchThreadID)
{
    
    OutputImg[DTid.xy] = SceneImg[DTid.xy] + LensFlareImg[DTid.xy];
    
}