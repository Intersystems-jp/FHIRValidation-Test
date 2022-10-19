Class ISJSample.FHIRBundleValidator Extends HS.FHIRServer.Util.BundleValidator
{

ClassMethod ValidateBundle(pResourceObject As %Library.DynamicObject, pFHIRVersion As %String)
{
    //do ##super(pResourceObject,pFHIRVersion)
    do ##class(ISJSample.FHIRValidation).validate(pResourceObject)
}

}
