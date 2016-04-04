# metro_surround

##プロダクト

see [App Store](https://itunes.apple.com/jp/app/dokochika-dong-jingmetoro/id1006534530?mt=8)

##CocoaPodsをインストール

各種ライブラリを使用しているので[CocoaPods](http://cocoapods.org) をインストールしてください。

CocoaPodsをインストール
```bash
$ gem install cocoapods
```

Podfileに記載されているライブラリをインストール
```bash
$ pod install
```

##設定方法
(1)[東京メトロのAPI](https://developer.tokyometroapp.jp/info)を利用していますので、キーを取得してください。

(2)`classes/AppDelegate.m`の`TOKYO_METRO_API_KEY`に取得したAPIキーを記載する。

```Objective-C
#import "AppDelegate.h"

static NSString *TOKYO_METRO_API_KEY = @"東京メトロAPIキーを設定してください";

@interface AppDelegate ()

@end
```
