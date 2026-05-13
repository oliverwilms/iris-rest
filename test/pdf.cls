Class test.pdf
{

ClassMethod CallRESTapi(pIris As %String, pUrl As %String, ByRef pResponseData As %DynamicObject, pType As %String = "GET", pSOAPFlag As %String = "", pBody = "") As %Status
{
	#define maxRESTapiErr 3
	#define maxRetries 2
	//#define timeout 12
	Do ..DebugTEST("Oliver.Util - CallRESTapi")
	Do ..DebugTEST("pIris = "_$Get(pIris))
	Do ..DebugTEST("pUrl = "_$Get(pUrl))
	Do ..DebugTEST("pType = "_$Get(pType))
	Do ..DebugTEST("pSOAPFlag = "_$Get(pSOAPFlag))
	Set myUnitTest = $Get(^myUnitTests)
	Set tErrorCount = 0
	Set tParamIRIS = pIris
	If (pIris = 0) Set pIris = "127.0.0.1:52773"
	Set tServer = $Piece(pIris,":",1)
	Set tPort = $Piece(pIris,":",2)
	Do {
		Set tRetryFlag = 0
		Set pResponse = $$$NULLOREF
		Set tRequest = ##class(%Net.HttpRequest).%New()
		If (pSOAPFlag = "@") {
			Set tSC = ..InsertMulti(.tRequest)
			Do ..DebugTEST("CT = "_tRequest.ContentType)
			Set pSOAPFlag = ""
		}
		If (pBody '= "") {
			Do tRequest.EntityBody.Write(pBody)
			Do ..DebugTEST("Oliver.Util - pBody")

		}
		If (tPort = 443) {
			Set tRequest.Https = 1
			Set tRequest.SSLCheckServerIdentity = 0
			Set tRequest.SSLConfiguration = "ISC.FeatureTracker.SSL.Config"
			Do ..DebugTEST("SSLConfiguration = "_tRequest.SSLConfiguration)
		}
		// InitiateAuthentication does not exist in HealthShare versions
		Try {
			//Supported schemes are Negotiate, NTLM and Basic.
			Set tRequest.InitiateAuthentication = "Basic"
			Set tReturn = ""
		  If ("" = tReturn) {
			Set tRequest.Username = "_SYSTEM"
			Set tRequest.Password = "SYS"  // ..GetPass(pIris)
			Do ..DebugTEST("Oliver.Util - SYS")
		  } Else {
			Set delim = $Extract(tReturn,1,1)			  
			Set tRequest.Username = $Piece(tReturn,delim,2)
			Set tRequest.Password = $Piece(tReturn,delim,3)
		  }
		} Catch {
		}
		//Set tRequest.Server = ""  // This defaults to 'localhost', i.e. your current machine if not specified.
		Set tRequest.Port = tPort
		If (tServer '= "") Set tRequest.Server = tServer
		Set tTimeout = ..GetTimeoutREST()
		Do ..DebugTEST("tTimeout = "_$Get(tTimeout))
		Set tRequest.Timeout = tTimeout
		Set type = $Get(pType)
		Set location = $Get(pUrl)
		Set test = 0
		Set reset = 1
		Do ..DebugTEST("location = "_$Get(location))
		Do ..DebugTEST("CT2 = "_tRequest.ContentType)
		//Set tSC = tRequest.SetHeader("Content-Type",tRequest.ContentType)
		//If $$$ISERR(tSC) Do ..DebugStatus(tSC)
		Set tSC = tRequest.Send(type,location,test,reset)
		If $$$ISERR(tSC) Do ..DebugStatus(tSC)
		If (tPort = 443) {
			Do ..DebugTEST("SSLError = "_tRequest.SSLError)
		}
		Set pResponse = tRequest.HttpResponse
		Do ..DebugTEST("HttpResponse = "_pResponse)
		If $IsObject(pResponse) {
			If (pResponse.StatusCode '= 200) {
				Do ..DebugTEST("StatusCode = "_pResponse.StatusCode)
				Do ..DebugTEST("ReasonPhrase = "_pResponse.ReasonPhrase)
			}
			If (pResponse.StatusCode = 500) {  // Internal Server Error
				If $Increment(tErrorCount) <= $$$maxRetries Set tRetryFlag = 1
			}
		} Else {
			//Do ..DebugTEST("HttpResponse = "_pResponse)
		}
	} While tRetryFlag

	If $IsObject(pResponse) {
		#dim tDataStream As %Stream.FileCharacterGzip
		Set tDataStream = pResponse.Data
		Do ..DebugTEST("tDataStream = "_pResponse.Data)
		Set tSize = tDataStream.Size
		Do ..DebugTEST("tDataStream.Size = "_tSize)
		Set tDataString = tDataStream.Read(.len,.sc)
		If $$$ISOK(sc) {
			Do ..DebugTEST("tDataString = "_tDataString)
		} Else {
			Do ..DebugTEST("Data = "_pResponse.Data)
			Do ..DebugTEST("len = "_$Get(len))
			Do ..DebugStatus(sc)
		}
		Try {
			//Set pResponseData = ##class(%DynamicObject).%FromJSON(tDataString)
		}
		Catch {
			//Set tSC = $$$ERROR($$$GeneralError,"JSON error")
			If (pResponse.StatusCode '= 200) {
				Set tSC = $$$ERROR($$$GeneralError,"Response was "_pResponse.StatusCode_" / "_pResponse.ReasonPhrase)
				Do ..DebugStatus(tSC)
			}
			//Do ..DebugStatus(tSC)
		}
		Set pResponseData = pResponse.Data
		Set tFileStream = ##class(%Stream.FileCharacter).%New()
		Set tFileStream.Filename = ..GetTestConfigResponseFilename()
		Set tSC = tDataStream.Rewind()
		While (0 = tDataStream.AtEnd) {
			Set tDataString = tDataStream.Read(.len,.sc)
			//zw len
			//zw sc
			Set tSC = tFileStream.Write(tDataString)
			//zw tSC
		}
		Set tSC = tFileStream.%Save()
		If $$$ISERR(tSC) Do ..DebugStatus(tSC)
		//zw tFileStream

	}
	Quit tSC
}

ClassMethod DebugMerge(strMessage As %String = "", ByRef pArray) As %Status
{
	Merge ^TESTunit($I(^TESTunit)) = pArray
	Set tValue = ""
	If $Get(pArray) '= "" Set tValue = " = "_pArray
	Set ^TESTunit(^TESTunit) = $ZDateTime($NOW(),8,1,3)_" : "_$JOB_" : "_strMessage_tValue
	Quit $$$OK
}

ClassMethod DebugTEST(strMessage As %String = "") As %Status
{
	Set ^TESTunit($I(^TESTunit)) = $ZDateTime($NOW(),8,1,3)_" : "_$JOB_" : "_strMessage
	Quit $$$OK
}

ClassMethod StatusToText(pStatus As %Status) As %String
{
	Set tReturn = $System.Status.GetOneErrorText(pStatus)
	Quit tReturn
}

ClassMethod DebugStatus(pStatus As %Status) As %Status
{
	Set tStatus = ..StatusToText(pStatus)
	Quit ..DebugTEST(tStatus)
}

ClassMethod GetStatusText(pStatus As %Status) As %String
{
	If $$$ISOK(pStatus) Quit "OK"
	Set tErrorText = $SYSTEM.Status.GetErrorText(pStatus)
	Set tReturn = $REPLACE(tErrorText,"ERROR #5001:","")
	Quit tReturn
}

ClassMethod GetTestConfigIRIS(pIris As %String = "oliver-test") As %String
{
	Set tReturn = $Get(^myFeeder("Config","Test","IRIS",pIris))
	Quit tReturn
}

ClassMethod GetTestConfigResponseFilename() As %String
{
	Quit "CallRESTresponse.xml"
}

ClassMethod GetTimeoutREST() As %String
{
	#define timeout 30
	Set tDefaultTimeout = $$$timeout
	Set tTimeoutREST = $Get(^myFeeder("Config","Util","Timeout","REST"),tDefaultTimeout)
	Set tReturn = tTimeoutREST
	Quit tReturn
}

ClassMethod InsertMulti(ByRef pRequest As %Net.HttpRequest) As %Status
{
	Set xmlPart = ##class(%Net.MIMEPart).%New()
	Set xmlStream = ##class(%GlobalCharacterStream).%New()
	Do xmlStream.Write("description")
	Set xmlPart.ContentType = "text/plain"
	Set xmlPart.Body = xmlStream
	Set tHeaderValue = "form-data; name='description'"
	Set tHeaderValue = $Replace(tHeaderValue,"'","""")
	Do xmlPart.SetHeader("Content-Disposition", tHeaderValue)
	Set rootMIME = ##class(%Net.MIMEPart).%New()
	Set rootMIME.ContentType = "multipart/form-data"
	Do rootMIME.Parts.Insert(xmlPart)
	Set pFile = "D:\tmp1\EU_MJB_#284_TSH_TEST.pdf"
	Set filePart = ..InsertMultiGetFilePart(pFile)
	Do rootMIME.Parts.Insert(filePart)
	//Set pRequest.ContentType = "multipart/related; type=text/xml; boundary="_rootMIME.Boundary
	Set tSC = pRequest.SetHeader("Content-Type","multipart/form-data; boundary="_rootMIME.Boundary)
	Do ..DebugTEST("IM-CT = "_pRequest.ContentType)
	Set writer = ##class(%Net.MIMEWriter).%New()
	Do writer.OutputToStream(pRequest.EntityBody)
	Do writer.WriteMIMEBody(rootMIME)
	Quit $$$OK
}

ClassMethod InsertMultiGetFilePart(pFile As %String = "") As %Net.MIMEPart
{
	Set filePart = ##class(%Net.MIMEPart).%New()
	Set fileStream = ##class(%Stream.FileBinary).%New()
	Set sc = fileStream.LinkToFile(pFile)
	Set filePart.Body = fileStream
	Set filePart.ContentType = "application/pdf"
	Set tHeaderValue = "form-data; name='file'; filename='myPDFfile.pdf'"
	Set tHeaderValue = $Replace(tHeaderValue,"'","""")
	Do filePart.SetHeader("Content-Disposition", tHeaderValue)
	Quit filePart
}

/*
WRC# 1011221 
Hello Oliver.
I came to the conclusion that the error that you are seeing is caused by a problem in your test.pdf.cls calling code, 
rather than in the REST service that has been generated from the OpenAPI javascript spec.

What led me to that conclusion was that I tried calling the REST service using curl, rather than from the TestRESTpdf() method in test.pdf.cls, something like this:
curl -v -u _SYSTEM:SYS -F "description=description" -F "file=@C:\temp\test.pdf;type=application/pdf" http://127.0.0.1:80/iris/pdf/upload-pdf

When I did this, I did not see the error about "Parameter required: file".

I then looked at the difference between what the curl command was sending and what test.pdf.cls was sending, and saw that in test.pdf.cls, InsertMulti() creates a multipart MIME body and sets this:

Set pRequest.ContentType = "multipart/related; type=text/xml; boundary="_rootMIME.Boundary

but later CallRESTapi() does this:

Set tSC = tRequest.SetHeader("Content-Type","multipart/form-data")

That later line is what reaches the server, and it loses the boundary. Both pieces are visible in test.pdf.cls.

There is also a subtype mismatch: this should be multipart/form-data, not multipart/related.

So I made corrections to test.pdf.cls. In InsertMulti(), change this:

Set pRequest.ContentType = "multipart/related; type=text/xml; boundary="_rootMIME.Boundary

to this:

Set rootMIME.ContentType = "multipart/form-data"

Set pRequest.ContentType = "multipart/form-data; boundary="_rootMIME.Boundary

Then in CallRESTapi(), remove or comment out this line:

Set tSC = tRequest.SetHeader("Content-Type","multipart/form-data")

After making those changes, I no longer see the error when I call  TestRESTpdf().

Please can you read what I've written, and confirm that the changes I've made make sense and fix the problem for you?

Do you need further information or assistance with this? Please let me know. Thank you.

Best regards,

Iain
Iain MacDonald
Iain.MacDonald@intersystems.com
*/
ClassMethod TestRESTpdf(pFlag As %String = "", pKill = 1) As %Status
{
	If pKill Kill ^TESTunit
	Do ..DebugTEST("test.pdf - TestRESTpdf")
	Set tSC = $$$OK
	Set pIris = ..GetTestConfigIRIS("oliver-test")
	If ("p" = $Extract(pFlag,1,1)) Set pIris = ..GetTestConfigIRIS("portal")
	Set pUrl = "/pdf/upload-pdf"
	If ("p" = $Extract(pFlag,1,1)) Set pUrl = "/csp/pdf/EnsLib.REST.GenericService/upload-pdf"
	If ("t" = $Extract(pFlag,1,1)) Set pUrl = "/pdf/test"
	Set pType = "POST"
	If ("t" = $Extract(pFlag,1,1)) Set pType = "GET"
	Set pSOAPflag = "@"
	Set tSC = ..CallRESTapi(pIris,pUrl,.pResponseData,pType,pSOAPflag)
	zw pResponseData
	Quit tSC
}

}
