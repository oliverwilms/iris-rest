# iris-rest
```
echo "# iris-rest" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/oliverwilms/iris-rest.git
git push -u origin main
```

https://docs.intersystems.com/iris20261/csp/docbook/DocBook.UI.Page.cls?KEY=GREST_mgmnt#GREST_mgmnt_class_create

Obtain the OpenAPI 2.0 specification for the REST service, in JSON format, and save the specification as a file. The file must be UTF-8 encoded.

I consulted Copilot to produce the specification.

https://github.com/oliverwilms/iris-rest/blob/main/openapi/upload_pdf_openapi_2_spec.json

In the namespace where you want to define the REST service, use the file to create an instance of %DynamicObject.

Then call the CreateApplication() method of the %REST.API class.

```
classmethod CreateApplication(applicationName As %String, 
                              swagger As %DynamicObject = "", 
                              ByRef features, 
                              Output newApplication As %Boolean, 
                              Output internalError As %Boolean) 
                              as %Status
```

```
Set obj = {}.%FromJSONFile("/upload_pdf_openapi_2_spec.json")
zw ##class(%REST.API).CreateApplication("pdf",obj,.features,.new,.err)
```

Create a web application with pdf.disp as Dispatch class

![screenshot](https://github.com/oliverwilms/bilder/blob/main/pdf_Web_Application.png)

Test the REST API from IRIS terminal:
```
Do ##class(test.pdf).TestRESTpdf("")
```


```
"{"_$c(13,10,9)_"""errors"":[ {"_$c(13,10,9,9,9)_"""code"":8727,"_$c(13,10,9,9,9)_"""domain"":""%ObjectErrors"","_$c(13,10,9,9,9)_"""error"":""ERROR #8727: Parameter required: file."","_$c(13,10,9,9,9)_"""id"":""RESTRequired"","_$c(13,10,9,9,9)_"""params"":[""file"""_$c(13,10,9,9,9)_"]"_$c(13,10,9,9)_"}"_$c(13,10,9)_"],"_$c(13,10,9)_"""summary"":""ERROR #8727: Parameter required: file."""_$c(13,10)_"}"
```

I sent test request to Interoperability production to review the request:
```
<?xml version="1.0" ?>
<!-- type: EnsLib.HTTP.GenericMessage  id: 143678 -->
<HTTPMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:s="http://www.w3.org/2001/XMLSchema">
<Stream><![CDATA[----boundary1987.1176470588235293863.941176470588235--
Content-Disposition: form-data; name="description"
CONTENT-TYPE: text/plain

description
----boundary1987.1176470588235293863.941176470588235--
Content-Disposition: form-data; name="file"; filename="myPDFfile.pdf"
CONTENT-TYPE: application/pdf

%PDF-1.4
%âãÏÓ
1 0 obj
<<
/CreationDate (D:20230624201210-04'00')
/ModDate (D:20230624201210-04'00')
/Creator (Xerox WorkCentre 6515DN)
/Producer (Xerox WorkCentre 6515DN)
>>
endobj
23 0 obj
```

```
trailer
<< /ID [<923DD5C850C0ACD373B300ED5FEFAA1F><E735B2AE72F6A0F62B72612C74850454> ] /Root 2 0 R /Size 44 /Prev 6938 /Info 1 0 R >> 
startxref
36724
%%EOF

----boundary1987.1176470588235293863.941176470588235----
]]></Stream>
<Type>GC</Type>
<HTTPHeaders>
<HTTPHeadersItem HTTPHeadersKey="CSPApplication">/csp/pdf/</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="CharEncoding" xsi:nil="true"></HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="EnsConfigName">EnsLib.REST.GenericService</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="HTTPVersion">1.1</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="HttpRequest">POST</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="IParams">0</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="RawParams" xsi:nil="true"></HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="TranslationTable">RAW</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="URL">/csp/pdf/EnsLib.REST.GenericService/upload-pdf</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="accept-encoding">gzip</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="authorization">Basic X1NZU1RFTTpTWVM=</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="content-length">37645</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="content-type">multipart/form-data</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="host">portal.zzzzzz.com</HTTPHeadersItem>
<HTTPHeadersItem HTTPHeadersKey="user-agent">Mozilla/4.0 (compatible; InterSystems IRIS;)</HTTPHeadersItem>
</HTTPHeaders>
</HTTPMessage>
<!-- Characters that could not be shown were removed for viewing purposes only -->
```
