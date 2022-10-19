Include HS.FHIRServer

/// このクラスはJavaのLanguageServer経由で外部検証を呼び出します
Class ISJSample.FHIRValidation [ Abstract ]
{

/// 1が設定されている場合 meta.profileが空または存在しない場合、リソースの検証をスキップします
Parameter SkipIfNoProfileKEY = "/FHIR/Validation/SkipIfNoProfile";

Parameter JavaGatewayPortKEY = "/FHIR/Validation/JavaGatewayPort";

Parameter JavaGatewayServerKEY = "/FHIR/Validation/JavaGatewayServer";

/// FHIRプロファイルの配置場所の指定
Parameter ProfileLocationKEY = "/FHIR/Validation/ProfileLocation";

/// TerminologyサーバのURL
Parameter TerminologyServerKEY = "/FHIR/Validation/TerminologyServer";

/// JavaGateway（JavaのLanguage Server）が起動しているかどうかチェックします
ClassMethod validate(theResource As %DynamicObject)
{
	#dim skipIfNoProfile As %String = ##class(HS.Registry.Config).GetKeyValue(..#SkipIfNoProfileKEY)

	// skipIfNoProfile: only validate if profile is specified
	if +skipIfNoProfile && 
			('theResource.%IsDefined("meta")
				|| 'theResource.meta.%IsDefined("profile") 
				|| (theResource.meta.profile.%Size() = 0))
	{
		quit
	}
	#dim javaGatewayPort As %String = ##class(HS.Registry.Config).GetKeyValue(..#JavaGatewayPortKEY)
	#dim javaGatewayServer As %String = ##class(HS.Registry.Config).GetKeyValue(..#JavaGatewayServerKEY)
	#dim profileLocation As %String = ##class(HS.Registry.Config).GetKeyValue(..#ProfileLocationKEY)
	#dim terminologyServer As %String = ##class(HS.Registry.Config).GetKeyValue(..#TerminologyServerKEY)
	

	// check if Java Gateway is up
	#dim sc As %Status = ##class(%Net.Remote.Service).PingGateway(javaGatewayPort, javaGatewayServer)
	if $$$ISERR(sc)
	{
		// assuming this is local gateway, try to start it
		$$$ThrowOnError(##class(%Net.Remote.Service).StartGateway("%Java Server"))
		set sc = $$$OK
	}

	// connect to gateway
	#dim gw As %Net.Remote.Gateway = ##class(%Net.Remote.Gateway).%New()
	$$$ThrowOnError(gw.%Connect(javaGatewayServer, javaGatewayPort))

	// generate proxy class if it's not present
	if '$$$comClassDefined("ISJSample.JavaValidatorFacade")
	{
		do ##class(%Net.Remote.Java.JavaGateway).%ExpressImport("ISJSample.JavaValidatorFacade", javaGatewayPort, javaGatewayServer, $$$YES)
	}

	// create temporary file with the resource
	#dim file As %Stream.FileCharacter = ##class(%Stream.FileCharacter).%New()
	set file.TranslateTable = "UTF8"
	do theResource.%ToJSON(file)
	do file.Flush()

	// run FHIR validator against the file
	#dim json As %String = ""
	try
	{
		$$$FSLog("About to call Java validator...")
		set json = ##class(ISJSample.JavaValidatorFacade).validate(gw, profileLocation, file.Filename, terminologyServer)
	}

	catch ex
	{
		set sc = $get(%objlasterror)  // exception with Java stack here!
		if (sc = "") set sc = ex.AsStatus()
	}
	kill file  // the file gets deleted here as we've never %Save()d it!

	$$$ThrowOnError(sc)


	// assemble error status in case of any severity=error issues
	#dim operationOutcome As %DynamicObject = {}.%FromJSON(json)

	#dim errorStatus As %Status = $$$OK
	#dim iter As %Iterator.Object = operationOutcome.issue.%GetIterator()
	#dim issue As %DynamicObject
	while iter.%GetNext(.key, .issue) 
	{
		if (issue.severity = "error")
		{
			#dim oneError As %Status = $$$ERROR($$$GeneralError, issue.details.text, $$$OutcomeWithPath(400, "error", issue.code, issue.expression.%Get(0)))
			$$$FHIRAddError(errorStatus, oneError)
		}
	}

	$$$ThrowOnError(errorStatus)
}

}
