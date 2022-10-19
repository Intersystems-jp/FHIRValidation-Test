Class ISJSample.FHIRValidationRepoManager Extends HS.FHIRServer.Storage.Json.RepoManager
{

/// カスタマイズ用に作成した InteractionStrategyのサブクラス名を指定
Parameter StrategyClass = "ISJSample.FHIRValidationInteractionsStrategy";

/// InteractionsStrategyで指定したStrategyKeyの値を指定（InteractionsStrategyクラス名に設定したのでクラス名が入る）
Parameter StrategyKey = "ISJSample.FHIRValidationInteractionsStrategy";

}
