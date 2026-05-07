/// API endpoint to upload a PDF document<br/>
/// Business logic class defined by OpenAPI in pdf.spec<br/>
/// Updated May 7, 2026 09:04:36
Class pdf.impl Extends %REST.Impl [ ProcedureBlock ]
{

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 0;

/// (provide functional description here)
/// WARNING: This method's signature has changed.
ClassMethod %RouteCB1() As %Stream.Object
{
    Set otw = $I(^IRISTEMP("pdf"))
    Set ^IRISTEMP("pdf",otw,"file")=$GET(file)
    Set ^IRISTEMP("pdf",otw,"desc")=$GET(description)
    //(Place business logic here)
    Do ..%SetStatusCode(200)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
    Quit "returnString"
}

/// Receives a PDF file from the client<br/>
/// The method arguments hold values for:<br/>
///     file, The PDF file to upload<br/>
///     description, Optional description of the PDF<br/>
ClassMethod %RouteCB2(file As %Stream.Object, description As %String) As %DynamicObject
{
    Set otw = $I(^IRISTEMP("pdf"))
    Set ^IRISTEMP("pdf",otw,"file")=$GET(file)
    Set ^IRISTEMP("pdf",otw,"desc")=$GET(description)
    //(Place business logic here)
    Do ..%SetStatusCode(200)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
    Quit "returnString"
}

/// (provide functional description here)
ClassMethod test() As %Stream.Object
{
    Set otw = $I(^IRISTEMP("pdf"))
    Set ^IRISTEMP("pdf",otw,"file")=$GET(file)
    Set ^IRISTEMP("pdf",otw,"desc")=$GET(description)
    //(Place business logic here)
    Do ..%SetStatusCode(200)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
    Quit "returnString"
}

/// Receives a PDF file from the client<br/>
/// The method arguments hold values for:<br/>
///     file, The PDF file to upload<br/>
///     description, Optional description of the PDF<br/>
ClassMethod uploadPDF(file As %Stream.Object, description As %String) As %DynamicObject
{
    Set otw = $I(^IRISTEMP("pdf"))
    Set ^IRISTEMP("pdf",otw,"file")=$GET(file)
    Set ^IRISTEMP("pdf",otw,"desc")=$GET(description)
    //(Place business logic here)
    Do ..%SetStatusCode(200)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
    Quit "returnString"
}

}
