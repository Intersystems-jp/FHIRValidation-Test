Class ISJSample.FHIRResourceValidator Extends HS.FHIRServer.Util.ResourceValidator
{

Method ValidateResource(pResourceObject As %DynamicObject)
{
    //do ##super(pResourceObject)
    if $get(%inTransactionFlag,$$$NO)'=$$$YES {
        do ##class(ISJSample.FHIRValidation).validate(pResourceObject)
    }
}

}
