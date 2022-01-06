package;
// source/AssetPaths.hx#L3-L10
/**
 * 輔助資產類別AssetPaths，
 * 該類別利用了Haxe的動態特徵，
 * 實時產生資產的對應欄位，
 * 這有助於在程式中以清晰的方式使用資產。
 */
@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
class AssetPaths {}