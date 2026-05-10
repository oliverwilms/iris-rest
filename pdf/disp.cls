/// API endpoint to upload a PDF document
/// Dispatch class defined by RESTSpec in pdf.spec
Class pdf.disp Extends %CSP.REST [ GeneratedBy = pdf.spec.cls, ProcedureBlock ]
{

/// The class containing the RESTSpec which generated this class
Parameter SpecificationClass = "pdf.spec";

/// Ignore any writes done directly by the REST method.
Parameter IgnoreWrites = 1;

/// By default convert the input stream to Unicode
Parameter CONVERTINPUTSTREAM = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/test" Method="get" Call="test" />
  <!-- Upload a PDF document -->
  <Route Url="/upload-pdf" Method="post" Call="uploadPDF" />
</Routes>
}

ClassMethod test() As %Status
{
    Try {
        Set response=##class(pdf.impl).test()
        Do ##class(pdf.impl).%WriteResponse(response)
    } Catch (ex) {
        Try {
            Do ##class(pdf.impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("pdf.impl","ExposeServerExceptions"))
        } Catch {
            Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("pdf.impl","ExposeServerExceptions"))
        }
    }
    Quit $$$OK
}

/// Upload a PDF document
ClassMethod uploadPDF() As %Status
{
    Try {
        If $case(%request.ContentType,"multipart/form-data":0,:1) {
            Try {
                Do ##class(pdf.impl).%ReportRESTError(..#HTTP415UNSUPPORTEDMEDIATYPE,$$$ERROR($$$RESTContentType,%request.ContentType))
            } Catch {
                Do ##class(%REST.Impl).%ReportRESTError(..#HTTP415UNSUPPORTEDMEDIATYPE,$$$ERROR($$$RESTContentType,%request.ContentType))
            }
            Quit
        }
        Do ##class(%REST.Impl).%SetContentType("application/json")
        If '##class(%REST.Impl).%CheckAccepts("application/json") {
            Try {
                Do ##class(pdf.impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts))
            } Catch {
                Do ##class(%REST.Impl).%ReportRESTError(..#HTTP406NOTACCEPTABLE,$$$ERROR($$$RESTBadAccepts))
            }
            Quit
        }
        If '$data(%request.MimeData("file",1)) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTRequired,"file")) Quit
        If $data(%request.MimeData("file",2)) {
            Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTDuplicate,"file")) Quit
        }
        Set pfile=%request.MimeData("file",1)
        Set stream=##class(%GlobalCharacterStream).%New()
        If $isobject(pfile) {
            Do pfile.Rewind()
            Set sc=stream.CopyFrom(pfile)
        } Else {
            Set sc=stream.Write(pfile)
        }
        If $$$ISERR(sc) Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTInvalid,"file",pfile)) Quit
        Set pfile=stream
        If $data(%request.Data("description",2)) {
            Do ##class(%REST.Impl).%ReportRESTError(..#HTTP400BADREQUEST,$$$ERROR($$$RESTDuplicate,"description")) Quit
        }
        If $data(%request.Data("description",1)) {
            Set pdescription=%request.Data("description",1)
        }
        Set response=##class(pdf.impl).uploadPDF(pfile,.pdescription)
        Do ##class(pdf.impl).%WriteResponse(response)
    } Catch (ex) {
        Try {
            Do ##class(pdf.impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("pdf.impl","ExposeServerExceptions"))
        } Catch {
            Do ##class(%REST.Impl).%ReportRESTError(..#HTTP500INTERNALSERVERERROR,ex.AsStatus(),$parameter("pdf.impl","ExposeServerExceptions"))
        }
    }
    Quit $$$OK
}

}
