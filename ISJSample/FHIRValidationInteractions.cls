Class ISJSample.FHIRValidationInteractions Extends HS.FHIRServer.Storage.Json.Interactions
{

/// 検証実行用カスタムクラス名（ISJSample.FHIRResourceValidator）を指定
Parameter ResourceValidatorClass = "ISJSample.FHIRResourceValidator";

Parameter BatchHandlerClass As %String = "ISJSample.FHIRBundleProcessor";

Method StartTransactionBundle(pBundleTransactionId As %Integer)
{
    do ##super(pBundleTransactionId)
    set %inTransactionFlag=$$$YES
}

Method EndTransactionBundle()
{
	kill %inTransactionFlag
    do ##super()
}

}
