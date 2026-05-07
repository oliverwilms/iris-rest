/// API endpoint to upload a PDF document<br/>
/// Business logic class defined by OpenAPI in pdf.spec<br/>
/// Created May 7, 2026 00:05:16
Class pdf.impl Extends %REST.Impl [ ProcedureBlock ]
{

/// If ExposeServerExceptions is true, then details of internal errors will be exposed.
Parameter ExposeServerExceptions = 0;

/// Receives a PDF file from the client<br/>
/// The method arguments hold values for:<br/>
///     file, The PDF file to upload<br/>
///     description, Optional description of the PDF<br/>
ClassMethod %RouteCB1(file As %Stream.Object, description As %String) As %DynamicObject
{
    //(Place business logic here)
    //Do ..%SetStatusCode(<HTTP_status_code>)
    //Do ..%SetHeader(<name>,<value>)
    //Quit (Place response here) ; response may be a string, stream or dynamic object
}

}
