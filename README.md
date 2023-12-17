# ディファードレンダリング・フォワードレンダリングについての考え

# 目標

- フォワードレンダリングとディファードレンダリングのそれぞれの利点、弱点の理解
- ディファードレンダリングをゲーム内に扱えるレベルまでの実装

# 実装

![実行画面](%E3%83%86%E3%82%99%E3%82%A3%E3%83%95%E3%82%A1%E3%83%BC%E3%83%88%E3%82%99%E3%83%AC%E3%83%B3%E3%82%BF%E3%82%99%E3%83%AA%E3%83%B3%E3%82%AF%E3%82%99%E3%83%BB%E3%83%95%E3%82%A9%E3%83%AF%E3%83%BC%E3%83%88%E3%82%99%E3%83%AC%E3%83%B3%E3%82%BF%E3%82%99%E3%83%AA%E3%83%B3%E3%82%AF%E3%82%99%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6%E3%81%AE%E8%80%83%E3%81%88%2030b911483acc443388fbc265670caf8a/DefferdRendering_%25E5%25AE%259F%25E8%25A1%258C%25E7%2594%25BB%25E9%259D%25A2.png)

実行画面

![箱の座標をそのまま点光源の座標としています。](%E3%83%86%E3%82%99%E3%82%A3%E3%83%95%E3%82%A1%E3%83%BC%E3%83%88%E3%82%99%E3%83%AC%E3%83%B3%E3%82%BF%E3%82%99%E3%83%AA%E3%83%B3%E3%82%AF%E3%82%99%E3%83%BB%E3%83%95%E3%82%A9%E3%83%AF%E3%83%BC%E3%83%88%E3%82%99%E3%83%AC%E3%83%B3%E3%82%BF%E3%82%99%E3%83%AA%E3%83%B3%E3%82%AF%E3%82%99%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6%E3%81%AE%E8%80%83%E3%81%88%2030b911483acc443388fbc265670caf8a/DefferdRendering_%25E7%2582%25B9%25E5%2585%2589%25E6%25BA%2590%25E8%25A1%25A8%25E7%25A4%25BA.png)

箱の座標をそのまま点光源の座標としています。

![半透明描画](%E3%83%86%E3%82%99%E3%82%A3%E3%83%95%E3%82%A1%E3%83%BC%E3%83%88%E3%82%99%E3%83%AC%E3%83%B3%E3%82%BF%E3%82%99%E3%83%AA%E3%83%B3%E3%82%AF%E3%82%99%E3%83%BB%E3%83%95%E3%82%A9%E3%83%AF%E3%83%BC%E3%83%88%E3%82%99%E3%83%AC%E3%83%B3%E3%82%BF%E3%82%99%E3%83%AA%E3%83%B3%E3%82%AF%E3%82%99%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6%E3%81%AE%E8%80%83%E3%81%88%2030b911483acc443388fbc265670caf8a/DefferdRendering_%25E5%258D%258A%25E9%2580%258F%25E6%2598%258E.png)

半透明描画

exe内には以下の処理が実装されています。

- スポンザ宮殿を1個+7種類のモデルを280個、計281個のモデルを描画
- 点光源を240個配置
- 半透明オブジェクトを1個配置

### 処理速度

現在使用できるPCで実行し、PIXで確認しました。(少数第3位以下は切り捨てています)

| GPU | 処理速度(ミリ秒) |
| --- | --- |
| RTX4070Ti | 1.40ms |
| GTX1660Ti | 5.38ms |

### 書き込まれているG-Bufferのフォーマット

| 用途 | フォーマット | R | G | B | A |
| --- | --- | --- | --- | --- | --- |
| Albedo | DXGI_FORMAT_R8G8B8A8_UNORM | テクスチャカラーのR成分 | テクスチャカラーのG成分 | テクスチャカラーのB成分 | テクスチャカラーのA成分 |
| world space - Normal | DXGI_FORMAT_R16G16B16A16_FLOAT | ワールド空間の法線ベクトルX | ワールド空間の法線ベクトルY | ワールド空間の法線ベクトルZ | 未使用 |
| World | DXGI_FORMAT_R32G32B32A32_FLOAT | ワールドX座標 | ワールドY座標 | ワールドZ座標 | 未使用 |

その他、MetalnessRoughness用やエミッシブ用のGBufferを用意していますがデモでは使用していないため、ここでは省きます。

### ソースコードの公開

- ディファーレンダリングの描画処理は「**Game/Scene/RenderScene」**内に書いています。
- 描画しているモデルをGBufferに書き込む処理は「Resource/ShaderFiles/ShaderFile/GBufferDrawFinal.hlsl」内に書いてあります。
- GBufferと多光源の合成の処理は「Resource/ShaderFiles/ShaderFile/GBufferDrawFinal.hlsl」
内に書いてあります。

# メリット・デメリット

- フォワードレンダリングとディファードレンダリングの描画処理の違い
- 何故ディファーレンダリングでは影の書き込みの計算が早いのか
- ディファードレンダリングのデメリットの解説とその対策

# 改善点

- **半透明オブジェクトの描画**

半透明のオブジェクトの描画はライティングパスを終えた後にフォワードレンダリングで描画する事で対策しています。ですが、半透明のオブジェクトが多くなる場合はディファードレンダリングの利点が薄くなると考えている為、別の対策が必要だと考えていますが、その対策は作る作品によって対策方法は変わると考えています。

- **無駄なフォーマットの使用**

32ビットと16ビットのフォーマットはどれも必ずアルファチャンネルを使用している為、無駄なスペースが出来ています。法線マップもビュー空間に直すことで修正できそう。

- **個数分のライトの計算処理**

BVHによるライトの送る数の対策。

# まとめ

- 何をもってしてゲームに活用できると考えているか
- フォワードレンダリングと比べて計算処理が大きく減らしているからゲームにも実用可能

きちんと内容を理解できているのか

# 参考文献

[](https://www.guerrilla-games.com/media/News/Files/Develop07_Valient_DeferredRenderingInKillzone2.pdf)

[【Unity】ForwardレンダリングとDeferredレンダリングの違いを軽くまとめてみた - Qiita](https://qiita.com/r-ngtm/items/a78ca2f72a36e2005da3)

[【Unity】【URP】URPにおけるディファードレンダリング - シェーダーTips](https://ny-program.hatenablog.com/entry/2022/09/30/232453#:~:text=ディファードレンダリングとは？,行います(ライティングパス)。)

[oFでDeferred Renderingしてみよう - Qiita](https://qiita.com/y_UM4/items/7647fd9fc19e60ec5822#はじめに)

[なぜなにリアルタイムレンダリング | ドクセル](https://www.docswell.com/s/2191436787/ZENEP7-2023-05-25-230031)